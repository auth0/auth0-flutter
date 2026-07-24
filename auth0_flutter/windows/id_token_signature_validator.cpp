/**
 * @file id_token_signature_validator.cpp
 * @brief JWT signature validation using the JWKS well-known endpoint
 */

#include "id_token_signature_validator.h"
#include "jwt_util.h"

#include <windows.h>
#include <wincrypt.h>
#pragma comment(lib, "Crypt32.lib")

#include <openssl/bn.h>
#include <openssl/core_names.h>
#include <openssl/evp.h>
#include <openssl/param_build.h>

#include <httplib.h>
#include <nlohmann/json.hpp>

#include <chrono>
#include <mutex>
#include <set>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace auth0_flutter
{

    // -------------------------------------------------------------------------
    // JWKS cache — keyed by jwksUri, TTL = 10 minutes
    // -------------------------------------------------------------------------

    namespace
    {
        struct JwksCacheEntry
        {
            nlohmann::json jwks;
            std::chrono::steady_clock::time_point fetchedAt;
        };

        std::mutex g_jwksCacheMutex;
        std::unordered_map<std::string, JwksCacheEntry> g_jwksCache;
        constexpr auto kJwksCacheTtl = std::chrono::minutes(10);
    } // anonymous namespace

    // -------------------------------------------------------------------------
    // Base64url decoding
    // -------------------------------------------------------------------------

    static std::vector<uint8_t> Base64UrlDecodeToBytes(const std::string &input)
    {
        std::string padded = input;
        std::replace(padded.begin(), padded.end(), '-', '+');
        std::replace(padded.begin(), padded.end(), '_', '/');
        while (padded.size() % 4 != 0)
            padded.push_back('=');

        DWORD outLen = 0;
        if (!CryptStringToBinaryA(
                padded.c_str(),
                static_cast<DWORD>(padded.size()),
                CRYPT_STRING_BASE64,
                nullptr,
                &outLen,
                nullptr,
                nullptr))
        {
            throw IdTokenValidationException("Base64url decode failed: unable to determine output size");
        }

        std::vector<uint8_t> output(outLen);
        if (!CryptStringToBinaryA(
                padded.c_str(),
                static_cast<DWORD>(padded.size()),
                CRYPT_STRING_BASE64,
                output.data(),
                &outLen,
                nullptr,
                nullptr))
        {
            throw IdTokenValidationException("Base64url decode failed: decoding error");
        }

        output.resize(outLen);
        return output;
    }

    // -------------------------------------------------------------------------
    // JWKS fetching
    // -------------------------------------------------------------------------

    // httplib::Client is constructed against a fixed scheme+host and takes a
    // bare path per request, unlike cpprestsdk's http_client which accepted
    // the full URL directly — split jwksUri into the two parts it needs.
    static std::pair<std::string, std::string> SplitJwksUri(const std::string &uri)
    {
        auto schemeEnd = uri.find("://");
        if (schemeEnd == std::string::npos)
        {
            throw IdTokenValidationException("Invalid JWKS URI: missing scheme");
        }

        auto pathStart = uri.find('/', schemeEnd + 3);
        if (pathStart == std::string::npos)
        {
            return {uri, "/"};
        }

        return {uri.substr(0, pathStart), uri.substr(pathStart)};
    }

    static nlohmann::json FetchJwksFromNetwork(const std::string &jwksUri)
    {
        auto [hostPart, path] = SplitJwksUri(jwksUri);

        httplib::Client client(hostPart);
        client.set_connection_timeout(10, 0);
        client.set_read_timeout(10, 0);

        auto response = client.Get(path);

        // cpp-httplib returns a null Result on connection failure instead of
        // throwing like cpprestsdk did — translate that into the same
        // exception type/message shape callers already expect.
        if (!response)
        {
            throw IdTokenValidationException(
                "Failed to fetch JWKS: " + httplib::to_string(response.error()));
        }

        if (response->status != 200)
        {
            throw IdTokenValidationException(
                "Failed to fetch JWKS: HTTP " +
                std::to_string(response->status));
        }

        try
        {
            return nlohmann::json::parse(response->body);
        }
        catch (const nlohmann::json::exception &ex)
        {
            throw IdTokenValidationException(
                std::string("Failed to fetch JWKS: ") + ex.what());
        }
    }

    static nlohmann::json FetchJwks(const std::string &jwksUri)
    {
        auto now = std::chrono::steady_clock::now();

        {
            std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
            auto it = g_jwksCache.find(jwksUri);
            if (it != g_jwksCache.end() &&
                (now - it->second.fetchedAt) < kJwksCacheTtl)
            {
                return it->second.jwks;
            }
        }

        nlohmann::json fresh = FetchJwksFromNetwork(jwksUri);

        {
            std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
            g_jwksCache[jwksUri] = {fresh, now};
        }

        return fresh;
    }

    // Search JWKS for key matching kid. Validates RFC 7517 "use" and "alg" fields.
    static nlohmann::json FindKeyByKid(
        const nlohmann::json &jwks,
        const std::string &kid)
    {
        // Verify JWKS has "keys" array; throw if missing or not an array
        if (!jwks.contains("keys") || !jwks.at("keys").is_array())
        {
            throw IdTokenValidationException("Invalid JWKS response: missing 'keys' array");
        }

        // Iterate through each key in the JWKS keys array
        for (const auto &jwk : jwks.at("keys"))
        {
            // Skip key if it doesn't have a "kid" field or "kid" is not a string
            if (!jwk.contains("kid") || !jwk.at("kid").is_string())
                continue;

            // Convert key's kid value to a string
            std::string jwkKid = jwk.at("kid").get<std::string>();

            // Check if this key's kid matches the requested kid
            if (jwkKid == kid)
            {
                // Check "use" field if present (must be "sig" for signature verification, not "enc")
                if (jwk.contains("use") && jwk.at("use").is_string())
                {
                    // Convert "use" field to string
                    std::string use = jwk.at("use").get<std::string>();
                    // Skip this key if "use" is not "sig" (prevents using encryption keys for signatures)
                    if (use != "sig")
                    {
                        continue;
                    }
                }

                // Check "alg" field if present (must be "RS256", our only supported algorithm)
                if (jwk.contains("alg") && jwk.at("alg").is_string())
                {
                    // Convert "alg" field to string
                    std::string alg = jwk.at("alg").get<std::string>();
                    // Skip this key if algorithm is not RS256 (prevents using keys for unsupported algorithms)
                    if (alg != "RS256")
                    {
                        continue;
                    }
                }

                // Return the key if all RFC 7517 validations passed
                return jwk;
            }
        }

        // Return null if no matching kid found after checking all keys
        return nlohmann::json(nullptr);
    }

    /**
     * @brief Build an RSA public key from JWK n/e components and verify
     *        an RSASSA-PKCS1-v1_5 signature with the given digest.
     */
    static bool VerifyRSASignature(
        const std::string &signingInput,
        const std::vector<uint8_t> &signature,
        const std::vector<uint8_t> &modulusBytes,
        const std::vector<uint8_t> &exponentBytes,
        const EVP_MD *digest)
    {
        BIGNUM *n = BN_bin2bn(modulusBytes.data(), static_cast<int>(modulusBytes.size()), nullptr);
        BIGNUM *e = BN_bin2bn(exponentBytes.data(), static_cast<int>(exponentBytes.size()), nullptr);

        if (!n || !e)
        {
            BN_free(n);
            BN_free(e);
            return false;
        }

        OSSL_PARAM_BLD *bld = OSSL_PARAM_BLD_new();
        if (!bld)
        {
            BN_free(n);
            BN_free(e);
            return false;
        }

        if (OSSL_PARAM_BLD_push_BN(bld, OSSL_PKEY_PARAM_RSA_N, n) != 1 ||
            OSSL_PARAM_BLD_push_BN(bld, OSSL_PKEY_PARAM_RSA_E, e) != 1)
        {
            OSSL_PARAM_BLD_free(bld);
            BN_free(n);
            BN_free(e);
            return false;
        }

        OSSL_PARAM *params = OSSL_PARAM_BLD_to_param(bld);
        OSSL_PARAM_BLD_free(bld);
        BN_free(n);
        BN_free(e);

        if (!params)
            return false;

        EVP_PKEY_CTX *pkeyCtx = EVP_PKEY_CTX_new_from_name(nullptr, "RSA", nullptr);
        if (!pkeyCtx)
        {
            OSSL_PARAM_free(params);
            return false;
        }

        EVP_PKEY *pkey = nullptr;
        if (EVP_PKEY_fromdata_init(pkeyCtx) != 1 ||
            EVP_PKEY_fromdata(pkeyCtx, &pkey, EVP_PKEY_PUBLIC_KEY, params) != 1)
        {
            EVP_PKEY_CTX_free(pkeyCtx);
            OSSL_PARAM_free(params);
            return false;
        }

        EVP_PKEY_CTX_free(pkeyCtx);
        OSSL_PARAM_free(params);

        EVP_MD_CTX *ctx = EVP_MD_CTX_new();
        if (!ctx)
        {
            EVP_PKEY_free(pkey);
            return false;
        }

        bool valid = false;
        if (EVP_DigestVerifyInit(ctx, nullptr, digest, nullptr, pkey) == 1 &&
            EVP_DigestVerifyUpdate(ctx, signingInput.data(), signingInput.size()) == 1)
        {
            valid = (EVP_DigestVerifyFinal(ctx, signature.data(), signature.size()) == 1);
        }

        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pkey);

        return valid;
    }

    /**
     * @brief Verify a JWT signature using the algorithm from the JWT header
     *        and the public key material from the matched JWK.
     *
     * Dispatches to the correct verification function based on the algorithm.
     * Currently supports RS256; extend the switch when adding new algorithms.
     */
    static bool VerifyWithAlgorithm(
        const std::string &alg,
        const std::string &signingInput,
        const std::vector<uint8_t> &signatureBytes,
        const nlohmann::json &jwk)
    {
        if (alg == "RS256")
        {
            if (!jwk.contains("n") || !jwk.contains("e"))
            {
                throw IdTokenValidationException(
                    "JWK is missing required RSA key material (n, e)");
            }

            std::string nStr = jwk.at("n").get<std::string>();
            std::string eStr = jwk.at("e").get<std::string>();

            std::vector<uint8_t> modulusBytes, exponentBytes;
            try
            {
                modulusBytes = Base64UrlDecodeToBytes(nStr);
                exponentBytes = Base64UrlDecodeToBytes(eStr);
            }
            catch (const IdTokenValidationException &)
            {
                throw;
            }
            catch (const std::exception &ex)
            {
                throw IdTokenValidationException(
                    std::string("Failed to decode JWK key material: ") + ex.what());
            }

            return VerifyRSASignature(signingInput, signatureBytes,
                                      modulusBytes, exponentBytes, EVP_sha256());
        }

        throw IdTokenValidationException(
            "Signature algorithm of \"" + alg +
            "\" is not supported. Expected the ID token to be signed with \"RS256\"");
    }

    /**
     * Validates the ID token signature
     *   1. Extract algorithm and kid from JWT header
     *   2. Fetch JWKS (with cache)
     *   3. Find JWK by kid
     *   4. Using the algorithm, verify the JWT with the JWK
     */
    void ValidateIdTokenSignature(
        const std::string &idToken,
        const std::string &jwksUri)
    {
        // --- 1. Extract algorithm and kid from JWT header ---
        nlohmann::json header;
        try
        {
            header = DecodeJwtHeader(idToken);
        }
        catch (const std::exception &ex)
        {
            throw IdTokenValidationException(
                std::string("Failed to decode ID token header: ") + ex.what());
        }

        std::string alg;
        if (header.contains("alg") && header.at("alg").is_string())
        {
            alg = header.at("alg").get<std::string>();
        }
        if (alg.empty())
        {
            throw IdTokenValidationException(
                "Signature algorithm of \"none\" is not supported. "
                "Expected the ID token to be signed with \"RS256\"");
        }

        static const std::set<std::string> kSupportedAlgorithms = {"RS256"};
        if (kSupportedAlgorithms.find(alg) == kSupportedAlgorithms.end())
        {
            throw IdTokenValidationException(
                "Signature algorithm of \"" + alg +
                "\" is not supported. Expected the ID token to be signed with \"RS256\"");
        }

        std::string kid;
        if (header.contains("kid") && header.at("kid").is_string())
        {
            kid = header.at("kid").get<std::string>();
        }
        if (kid.empty())
        {
            throw IdTokenValidationException(
                "Could not find a public key for Key ID (kid) \"\"");
        }

        // --- 2. Fetch JWKS ---
        nlohmann::json jwks;
        try
        {
            jwks = FetchJwks(jwksUri);
        }
        catch (const IdTokenValidationException &)
        {
            throw;
        }
        catch (const std::exception &ex)
        {
            throw IdTokenValidationException(
                std::string("Failed to fetch JWKS: ") + ex.what());
        }

        // Prepare signing input and decoded signature
        auto parts = SplitJwt(idToken);
        const std::string signingInput = parts.header + "." + parts.payload;

        std::vector<uint8_t> signatureBytes;
        try
        {
            signatureBytes = Base64UrlDecodeToBytes(parts.signature);
        }
        catch (const IdTokenValidationException &)
        {
            throw;
        }
        catch (const std::exception &ex)
        {
            throw IdTokenValidationException(
                std::string("Failed to decode JWT signature: ") + ex.what());
        }

        // --- 3. Find JWK by kid ---
        nlohmann::json jwk = FindKeyByKid(jwks, kid);

        if (jwk.is_null())
        {
            // Kid not in cached JWKS — evict and retry with fresh fetch.
            {
                std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
                g_jwksCache.erase(jwksUri);
            }
            try
            {
                jwks = FetchJwksFromNetwork(jwksUri);
                {
                    std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
                    g_jwksCache[jwksUri] = {jwks, std::chrono::steady_clock::now()};
                }
            }
            catch (const std::exception &ex)
            {
                throw IdTokenValidationException(
                    std::string("Failed to fetch JWKS: ") + ex.what());
            }

            jwk = FindKeyByKid(jwks, kid);
            if (jwk.is_null())
            {
                throw IdTokenValidationException(
                    "Could not find a public key for Key ID (kid) \"" + kid + "\"");
            }
        }

        // --- 4. Using the algorithm, verify the JWT with the JWK ---
        bool verified = VerifyWithAlgorithm(alg, signingInput, signatureBytes, jwk);

        if (!verified)
        {
            // Signature mismatch — may be a key rotation. Evict cache and retry once.
            {
                std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
                g_jwksCache.erase(jwksUri);
            }
            try
            {
                jwks = FetchJwksFromNetwork(jwksUri);
                {
                    std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
                    g_jwksCache[jwksUri] = {jwks, std::chrono::steady_clock::now()};
                }
            }
            catch (const std::exception &ex)
            {
                throw IdTokenValidationException(
                    std::string("Failed to fetch JWKS: ") + ex.what());
            }

            jwk = FindKeyByKid(jwks, kid);
            if (jwk.is_null())
            {
                throw IdTokenValidationException(
                    "Could not find a public key for Key ID (kid) \"" + kid + "\"");
            }

            verified = VerifyWithAlgorithm(alg, signingInput, signatureBytes, jwk);
        }

        if (!verified)
        {
            throw IdTokenValidationException("Invalid ID token signature");
        }
    }

} // namespace auth0_flutter
