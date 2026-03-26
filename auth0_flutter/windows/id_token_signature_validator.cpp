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

#include <cpprest/http_client.h>
#include <cpprest/json.h>

#include <chrono>
#include <mutex>
#include <set>
#include <stdexcept>
#include <string>
#include <unordered_map>
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
            web::json::value jwks;
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

    static web::json::value FetchJwksFromNetwork(const std::string &jwksUri)
    {
        web::http::client::http_client_config config;
        config.set_timeout(std::chrono::seconds(10));
        web::http::client::http_client client(
            utility::conversions::to_string_t(jwksUri), config);

        auto response = client.request(web::http::methods::GET).get();

        if (response.status_code() != web::http::status_codes::OK)
        {
            throw IdTokenValidationException(
                "Failed to fetch JWKS: HTTP " +
                std::to_string(response.status_code()));
        }

        return response.extract_json().get();
    }

    static web::json::value FetchJwks(const std::string &jwksUri)
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

        web::json::value fresh = FetchJwksFromNetwork(jwksUri);

        {
            std::lock_guard<std::mutex> lock(g_jwksCacheMutex);
            g_jwksCache[jwksUri] = {fresh, now};
        }

        return fresh;
    }

    /**
     * @brief Search a JWKS for a key matching @p kid.
     *
     * @param jwks  Parsed JWKS JSON value
     * @param kid   Key ID to locate
     * @return The matching JWK JSON value, or a null json value if not found.
     */
    static web::json::value FindKeyByKid(
        const web::json::value &jwks,
        const std::string &kid)
    {
        if (!jwks.has_field(U("keys")) || !jwks.at(U("keys")).is_array())
        {
            throw IdTokenValidationException("Invalid JWKS response: missing 'keys' array");
        }

        for (const auto &jwk : jwks.at(U("keys")).as_array())
        {
            if (!jwk.has_field(U("kid")) || !jwk.at(U("kid")).is_string())
                continue;

            std::string jwkKid =
                utility::conversions::to_utf8string(jwk.at(U("kid")).as_string());

            if (jwkKid == kid)
                return jwk;
        }

        return web::json::value::null();
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
        const web::json::value &jwk)
    {
        if (alg == "RS256")
        {
            if (!jwk.has_field(U("n")) || !jwk.has_field(U("e")))
            {
                throw IdTokenValidationException(
                    "JWK is missing required RSA key material (n, e)");
            }

            std::string nStr = utility::conversions::to_utf8string(jwk.at(U("n")).as_string());
            std::string eStr = utility::conversions::to_utf8string(jwk.at(U("e")).as_string());

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
        web::json::value header;
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
        if (header.has_field(U("alg")) && header.at(U("alg")).is_string())
        {
            alg = utility::conversions::to_utf8string(header.at(U("alg")).as_string());
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
        if (header.has_field(U("kid")) && header.at(U("kid")).is_string())
        {
            kid = utility::conversions::to_utf8string(header.at(U("kid")).as_string());
        }
        if (kid.empty())
        {
            throw IdTokenValidationException(
                "Could not find a public key for Key ID (kid) \"\"");
        }

        // --- 2. Fetch JWKS ---
        web::json::value jwks;
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
        web::json::value jwk = FindKeyByKid(jwks, kid);

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
