/**
 * @file id_token_validator.cpp
 * @brief Implementation of ID Token validation
 */

#include "id_token_validator.h"
#include "id_token_signature_validator.h"
#include "jwt_util.h"
#include <chrono>
#include <sstream>
#include <algorithm>

namespace auth0_flutter
{

    /**
     * @brief Get current time as Unix timestamp (seconds since epoch)
     */
    static int64_t GetCurrentTimestamp()
    {
        auto now = std::chrono::system_clock::now();
        auto duration = now.time_since_epoch();
        return std::chrono::duration_cast<std::chrono::seconds>(duration).count();
    }

    /**
     * @brief Extract a required string claim from JWT payload
     */
    static std::string GetRequiredStringClaim(
        const web::json::value &payload,
        const std::string &claimName)
    {
        if (!payload.has_field(utility::conversions::to_string_t(claimName)))
        {
            throw IdTokenValidationException("Missing required claim: " + claimName);
        }

        const auto &field = payload.at(utility::conversions::to_string_t(claimName));
        if (!field.is_string())
        {
            throw IdTokenValidationException("Claim '" + claimName + "' is not a string");
        }

        return utility::conversions::to_utf8string(field.as_string());
    }

    /**
     * @brief Extract a required integer claim from JWT payload
     */
    static int64_t GetRequiredIntClaim(
        const web::json::value &payload,
        const std::string &claimName)
    {
        if (!payload.has_field(utility::conversions::to_string_t(claimName)))
        {
            throw IdTokenValidationException("Missing required claim: " + claimName);
        }

        const auto &field = payload.at(utility::conversions::to_string_t(claimName));
        if (!field.is_number())
        {
            throw IdTokenValidationException("Claim '" + claimName + "' is not a number");
        }

        return field.as_number().to_int64();
    }

    /**
     * @brief Extract an optional integer claim from JWT payload
     */
    static std::optional<int64_t> GetOptionalIntClaim(
        const web::json::value &payload,
        const std::string &claimName)
    {
        if (!payload.has_field(utility::conversions::to_string_t(claimName)))
        {
            return std::nullopt;
        }

        const auto &field = payload.at(utility::conversions::to_string_t(claimName));
        if (!field.is_number())
        {
            return std::nullopt;
        }

        return field.as_number().to_int64();
    }

    /**
     * @brief Extract an optional string claim from JWT payload
     */
    static std::optional<std::string> GetOptionalStringClaim(
        const web::json::value &payload,
        const std::string &claimName)
    {
        if (!payload.has_field(utility::conversions::to_string_t(claimName)))
        {
            return std::nullopt;
        }

        const auto &field = payload.at(utility::conversions::to_string_t(claimName));
        if (!field.is_string())
        {
            return std::nullopt;
        }

        return utility::conversions::to_utf8string(field.as_string());
    }

    void ValidateIdToken(
        const std::string &idToken,
        const IdTokenValidationConfig &config,
        web::json::value *outPayload)
    {
        if (idToken.empty())
        {
            throw IdTokenValidationException("ID token is empty");
        }

        // Signature validation (RS256 via JWKS) – performed before claims validation
        // to match the OIDC specification and Auth0.swift ordering.
        // Skipped when jwksUri is not provided (e.g. in unit tests).
        if (config.jwksUri.has_value() && !config.jwksUri.value().empty())
        {
            ValidateIdTokenSignature(idToken, config.jwksUri.value());
        }

        // Decode JWT payload
        web::json::value payload;
        try
        {
            payload = DecodeJwtPayload(idToken);
        }
        catch (const std::exception &e)
        {
            throw IdTokenValidationException(std::string("Failed to decode ID token: ") + e.what());
        }

        // Get current timestamp for time-based validations
        int64_t now = GetCurrentTimestamp();

        // 1. Validate issuer (iss) claim
        std::string iss = GetRequiredStringClaim(payload, "iss");
        if (iss != config.issuer)
        {
            std::ostringstream msg;
            msg << "Invalid issuer. Expected: '" << config.issuer << "', Got: '" << iss << "'";
            throw IdTokenValidationException(msg.str());
        }

        // 2. Validate audience (aud) claim
        // The aud claim can be either a string or an array of strings
        if (!payload.has_field(U("aud")))
        {
            throw IdTokenValidationException("Missing required claim: aud");
        }

        const auto &audField = payload.at(U("aud"));
        bool audienceValid = false;

        if (audField.is_string())
        {
            std::string aud = utility::conversions::to_utf8string(audField.as_string());
            audienceValid = (aud == config.audience);
        }
        else if (audField.is_array())
        {
            const auto &audArray = audField.as_array();
            for (const auto &audValue : audArray)
            {
                if (audValue.is_string())
                {
                    std::string aud = utility::conversions::to_utf8string(audValue.as_string());
                    if (aud == config.audience)
                    {
                        audienceValid = true;
                        break;
                    }
                }
            }
        }

        if (!audienceValid)
        {
            std::ostringstream msg;
            msg << "Invalid audience. Expected: '" << config.audience << "'";
            throw IdTokenValidationException(msg.str());
        }

        // 3. Validate expiration time (exp) claim with leeway
        int64_t exp = GetRequiredIntClaim(payload, "exp");
        if (now > exp + config.leeway)
        {
            std::ostringstream msg;
            msg << "ID token has expired. Expiration time: " << exp
                << ", Current time: " << now
                << ", Leeway: " << config.leeway;
            throw IdTokenValidationException(msg.str());
        }

        // 4. Validate issued at (iat) claim
        // The iat claim must be present and should not be in the future (with leeway)
        int64_t iat = GetRequiredIntClaim(payload, "iat");
        if (iat > now + config.leeway)
        {
            std::ostringstream msg;
            msg << "ID token issued in the future. Issued at: " << iat
                << ", Current time: " << now
                << ", Leeway: " << config.leeway;
            throw IdTokenValidationException(msg.str());
        }

        // 5. Validate auth_time if maxAge is specified
        if (config.maxAge.has_value())
        {
            auto authTime = GetOptionalIntClaim(payload, "auth_time");
            if (!authTime.has_value())
            {
                throw IdTokenValidationException(
                    "Missing required claim 'auth_time' when maxAge is specified");
            }

            int64_t timeSinceAuth = now - authTime.value();
            if (timeSinceAuth > config.maxAge.value() + config.leeway)
            {
                std::ostringstream msg;
                msg << "Authentication is too old. auth_time: " << authTime.value()
                    << ", Current time: " << now
                    << ", maxAge: " << config.maxAge.value()
                    << ", Time since auth: " << timeSinceAuth;
                throw IdTokenValidationException(msg.str());
            }
        }

        // 6. Validate nonce if provided
        if (config.nonce.has_value())
        {
            auto nonce = GetOptionalStringClaim(payload, "nonce");
            if (!nonce.has_value())
            {
                throw IdTokenValidationException(
                    "Missing required claim 'nonce' when nonce was sent in authorization request");
            }

            if (nonce.value() != config.nonce.value())
            {
                std::ostringstream msg;
                msg << "Invalid nonce. Expected: '" << config.nonce.value()
                    << "', Got: '" << nonce.value() << "'";
                throw IdTokenValidationException(msg.str());
            }
        }

        // All validations passed - return payload if requested
        if (outPayload != nullptr)
        {
            *outPayload = payload;
        }
    }

} // namespace auth0_flutter
