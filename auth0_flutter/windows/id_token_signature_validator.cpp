/**
 * @file id_token_signature_validator.cpp
 * @brief RS256 signature validation using the JWKS well-known endpoint
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

#include <stdexcept>
#include <string>
#include <vector>

namespace auth0_flutter
{

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    /**
     * @brief Decode a Base64url-encoded string into raw bytes.
     *
     * Reuses Windows CryptStringToBinaryA (same approach as jwt_util.cpp).
     */
    static std::vector<uint8_t> Base64UrlDecodeToBytes(const std::string &input)
    {
        // Convert Base64url -> standard Base64 with padding
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

    /**
     * @brief Fetch the JWKS JSON from the given URI synchronously.
     */
    static web::json::value FetchJwks(const std::string &jwksUri)
    {
        web::http::client::http_client client(
            utility::conversions::to_string_t(jwksUri));

        auto response = client.request(web::http::methods::GET).get();

        if (response.status_code() != web::http::status_codes::OK)
        {
            throw IdTokenValidationException(
                "Failed to fetch JWKS: HTTP " +
                std::to_string(response.status_code()));
        }

        return response.extract_json().get();
    }

    /**
     * @brief Verify an RS256 (RSASSA-PKCS1-v1_5 + SHA-256) signature.
     *
     * @param signingInput  The "header_b64url.payload_b64url" string
     * @param signature     Raw decoded signature bytes
     * @param modulusBytes  Raw decoded JWK 'n' bytes
     * @param exponentBytes Raw decoded JWK 'e' bytes
     * @return true if the signature is valid
     */
    static bool VerifyRS256Signature(
        const std::string &signingInput,
        const std::vector<uint8_t> &signature,
        const std::vector<uint8_t> &modulusBytes,
        const std::vector<uint8_t> &exponentBytes)
    {
        // Build BIGNUM values from the JWK modulus and exponent
        BIGNUM *n = BN_bin2bn(modulusBytes.data(), static_cast<int>(modulusBytes.size()), nullptr);
        BIGNUM *e = BN_bin2bn(exponentBytes.data(), static_cast<int>(exponentBytes.size()), nullptr);

        if (!n || !e)
        {
            BN_free(n);
            BN_free(e);
            return false;
        }

        // Build EVP_PKEY directly from BIGNUMs using the OpenSSL 3.0 provider API.
        // This avoids all deprecated RSA_* / EVP_PKEY_assign_RSA calls.
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

        // Verify using EVP_DigestVerify (SHA-256)
        EVP_MD_CTX *ctx = EVP_MD_CTX_new();
        if (!ctx)
        {
            EVP_PKEY_free(pkey);
            return false;
        }

        bool valid = false;
        if (EVP_DigestVerifyInit(ctx, nullptr, EVP_sha256(), nullptr, pkey) == 1 &&
            EVP_DigestVerifyUpdate(ctx, signingInput.data(), signingInput.size()) == 1)
        {
            valid = (EVP_DigestVerifyFinal(ctx, signature.data(), signature.size()) == 1);
        }

        EVP_MD_CTX_free(ctx);
        EVP_PKEY_free(pkey);

        return valid;
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    void ValidateIdTokenSignature(
        const std::string &idToken,
        const std::string &jwksUri)
    {
        // --- 1. Decode JWT header ---
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

        // --- 2. Validate algorithm – only RS256 is accepted ---
        const std::string expectedAlg = "RS256";
        std::string alg;

        if (header.has_field(U("alg")) && header.at(U("alg")).is_string())
        {
            alg = utility::conversions::to_utf8string(header.at(U("alg")).as_string());
        }

        if (alg != expectedAlg)
        {
            throw IdTokenValidationException(
                "Signature algorithm of \"" + (alg.empty() ? "none" : alg) +
                "\" is not supported. Expected the ID token to be signed with \"" +
                expectedAlg + "\"");
        }

        // --- 3. Extract kid (Key ID) ---
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

        // --- 4. Fetch JWKS from the well-known endpoint ---
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

        if (!jwks.has_field(U("keys")) || !jwks.at(U("keys")).is_array())
        {
            throw IdTokenValidationException("Invalid JWKS response: missing 'keys' array");
        }

        // --- 5. Find the JWK whose kid matches ---
        std::string matchedN, matchedE;
        bool foundKey = false;

        for (const auto &jwk : jwks.at(U("keys")).as_array())
        {
            if (!jwk.has_field(U("kid")) || !jwk.at(U("kid")).is_string())
                continue;

            const std::string jwkKid =
                utility::conversions::to_utf8string(jwk.at(U("kid")).as_string());

            if (jwkKid != kid)
                continue;

            // Must be an RSA key
            if (!jwk.has_field(U("kty")) || !jwk.at(U("kty")).is_string() ||
                utility::conversions::to_utf8string(jwk.at(U("kty")).as_string()) != "RSA")
            {
                continue;
            }

            if (!jwk.has_field(U("n")) || !jwk.has_field(U("e")))
                continue;

            matchedN = utility::conversions::to_utf8string(jwk.at(U("n")).as_string());
            matchedE = utility::conversions::to_utf8string(jwk.at(U("e")).as_string());
            foundKey = true;
            break;
        }

        if (!foundKey)
        {
            throw IdTokenValidationException(
                "Could not find a public key for Key ID (kid) \"" + kid + "\"");
        }

        // --- 6. Verify the RS256 signature ---
        // The signing input is the raw "header_b64url.payload_b64url" from the JWT
        auto parts = SplitJwt(idToken);
        const std::string signingInput = parts.header + "." + parts.payload;

        std::vector<uint8_t> signatureBytes, modulusBytes, exponentBytes;
        try
        {
            signatureBytes = Base64UrlDecodeToBytes(parts.signature);
            modulusBytes   = Base64UrlDecodeToBytes(matchedN);
            exponentBytes  = Base64UrlDecodeToBytes(matchedE);
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

        if (!VerifyRS256Signature(signingInput, signatureBytes, modulusBytes, exponentBytes))
        {
            throw IdTokenValidationException("Invalid ID token signature");
        }
    }

} // namespace auth0_flutter