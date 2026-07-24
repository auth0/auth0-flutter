/**
 * @file id_token_validator.cpp
 * @brief Implementation of ID Token validation
 */

#include "id_token_validator.h"
#include "id_token_signature_validator.h"
#include "jwt_util.h"
#include <algorithm>
#include <cctype>
#include <chrono>
#include <sstream>

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
     * @brief Extract a required integer claim from JWT payload
     */
    static int64_t GetRequiredIntClaim(
        const nlohmann::json &payload,
        const std::string &claimName)
    {
        if (!payload.contains(claimName))
        {
            throw IdTokenValidationException("Missing required claim: " + claimName);
        }

        const auto &field = payload.at(claimName);
        if (!field.is_number())
        {
            throw IdTokenValidationException("Claim '" + claimName + "' is not a number");
        }

        return field.get<int64_t>();
    }

    /**
     * @brief Extract an optional integer claim from JWT payload
     */
    static std::optional<int64_t> GetOptionalIntClaim(
        const nlohmann::json &payload,
        const std::string &claimName)
    {
        if (!payload.contains(claimName))
        {
            return std::nullopt;
        }

        const auto &field = payload.at(claimName);
        if (!field.is_number())
        {
            return std::nullopt;
        }

        return field.get<int64_t>();
    }

    /**
     * @brief Extract an optional string claim from JWT payload
     */
    static std::optional<std::string> GetOptionalStringClaim(
        const nlohmann::json &payload,
        const std::string &claimName)
    {
        if (!payload.contains(claimName))
        {
            return std::nullopt;
        }

        const auto &field = payload.at(claimName);
        if (!field.is_string())
        {
            return std::nullopt;
        }

        return field.get<std::string>();
    }

    void ValidateIdToken(
        const std::string &idToken,
        const IdTokenValidationConfig &config,
        nlohmann::json *outPayload)
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
        nlohmann::json payload;
        try
        {
            payload = DecodeJwtPayload(idToken);
        }
        catch (const std::exception &e)
        {
            throw IdTokenValidationException(std::string("ID token could not be decoded: ") + e.what());
        }

        // Get current Unix timestamp for time-based validations
        int64_t now = GetCurrentTimestamp();

        // 1. Validate issuer (iss) claim 
        {
            auto iss = GetOptionalStringClaim(payload, "iss");
            if (!iss.has_value())
            {
                throw IdTokenValidationException(
                    "Issuer (iss) claim must be a string present in the ID token");
            }
            if (iss.value() != config.issuer)
            {
                std::ostringstream msg;
                msg << "Issuer (iss) claim mismatch in the ID token, expected ("
                    << config.issuer << "), found (" << iss.value() << ")";
                throw IdTokenValidationException(msg.str());
            }
        }

        // 2. Validate subject (sub) claim
        {
            auto sub = GetOptionalStringClaim(payload, "sub");
            if (!sub.has_value() || sub.value().empty())
            {
                throw IdTokenValidationException(
                    "Subject (sub) claim must be a string present in the ID token");
            }
        }

        // 3. Validate audience (aud) claim
        // aud can be a string or an array of strings.
        if (!payload.contains("aud"))
        {
            throw IdTokenValidationException(
                "Audience (aud) claim must be a string or array of strings present in the ID token");
        }

        const auto &audField = payload.at("aud");

        if (audField.is_string())
        {
            std::string aud = audField.get<std::string>();
            if (aud != config.audience)
            {
                std::ostringstream msg;
                msg << "Audience (aud) claim mismatch in the ID token; expected ("
                    << config.audience << ") but found (" << aud << ")";
                throw IdTokenValidationException(msg.str());
            }
        }
        else if (audField.is_array())
        {
            if (audField.empty())
            {
                throw IdTokenValidationException(
                    "Audience (aud) claim must be a string or array of strings present in the ID token");
            }

            std::vector<std::string> audValues;
            bool found = false;
            for (const auto &v : audField)
            {
                if (v.is_string())
                {
                    std::string s = v.get<std::string>();
                    audValues.push_back(s);
                    if (s == config.audience) found = true;
                }
            }
            if (!found)
            {
                std::ostringstream joined;
                for (size_t i = 0; i < audValues.size(); ++i)
                {
                    if (i > 0) joined << ", ";
                    joined << audValues[i];
                }
                std::ostringstream msg;
                msg << "Audience (aud) claim mismatch in the ID token; expected ("
                    << config.audience << ") but was not one of (" << joined.str() << ")";
                throw IdTokenValidationException(msg.str());
            }
        }
        else
        {
            throw IdTokenValidationException(
                "Audience (aud) claim must be a string or array of strings present in the ID token");
        }

        // 4. Validate expiration time (exp) claim
        {
            if (!payload.contains("exp"))
            {
                throw IdTokenValidationException(
                    "Expiration time (exp) claim must be a number present in the ID token");
            }
            int64_t exp = GetRequiredIntClaim(payload, "exp");
            double expWithLeeway = static_cast<double>(exp) + static_cast<double>(config.leeway);
            if (static_cast<double>(now) > expWithLeeway)
            {
                std::ostringstream msg;
                msg << "Expiration time (exp) claim error in the ID token; current time ("
                    << now << ") is after expiration time (" << expWithLeeway << ")";
                throw IdTokenValidationException(msg.str());
            }
        }

        // 5. Validate issued at (iat) claim
        if (!payload.contains("iat"))
        {
            throw IdTokenValidationException(
                "Issued At (iat) claim must be a number present in the ID token");
        }
        {
            int64_t iat = GetRequiredIntClaim(payload, "iat");
            if (static_cast<double>(iat) > static_cast<double>(now) + static_cast<double>(config.leeway))
            {
                std::ostringstream msg;
                msg << "Issued At (iat) claim error in the ID token; current time ("
                    << now << ") is before issued at time (" << iat << ")";
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
                    "Nonce (nonce) claim must be a string present in the ID token");
            }
            if (nonce.value() != config.nonce.value())
            {
                std::ostringstream msg;
                msg << "Nonce (nonce) claim value mismatch in the ID token; expected ("
                    << config.nonce.value() << "), found (" << nonce.value() << ")";
                throw IdTokenValidationException(msg.str());
            }
        }

        // 7. Validate azp (Authorized Party) when aud has multiple values
        if (audField.is_array() && audField.size() > 1)
        {
            auto azp = GetOptionalStringClaim(payload, "azp");
            if (!azp.has_value())
            {
                throw IdTokenValidationException(
                    "Authorized Party (azp) claim must be a string present in the ID token "
                    "when Audience (aud) claim has multiple values");
            }
            if (azp.value() != config.audience)
            {
                std::ostringstream msg;
                msg << "Authorized Party (azp) claim mismatch in the ID token; expected ("
                    << config.audience << "), found (" << azp.value() << ")";
                throw IdTokenValidationException(msg.str());
            }
        }

        // 8. Validate auth_time if maxAge is specified
        if (config.maxAge.has_value())
        {
            auto authTime = GetOptionalIntClaim(payload, "auth_time");
            if (!authTime.has_value())
            {
                throw IdTokenValidationException(
                    "Authentication Time (auth_time) claim must be a number present in the ID token "
                    "when Max Age (max_age) is specified");
            }
            double adjustedMaxAge = static_cast<double>(config.maxAge.value()) +
                                    static_cast<double>(config.leeway);
            double authTimeWithMax = static_cast<double>(authTime.value()) + adjustedMaxAge;
            if (static_cast<double>(now) > authTimeWithMax)
            {
                std::ostringstream msg;
                msg << "Authentication Time (auth_time) claim in the ID token indicates that "
                       "too much time has passed since the last user authentication. "
                       "Current time (" << now << ") is after last auth time (" << authTimeWithMax << ")";
                throw IdTokenValidationException(msg.str());
            }
        }

        // 9. Validate organization
        // Values starting with "org_" are org_id (exact match).
        // All other values are org_name (case-insensitive, Auth0 stores org_name in lowercase).
        if (config.organization.has_value() && !config.organization.value().empty())
        {
            const std::string &expectedOrg = config.organization.value();
            if (expectedOrg.rfind("org_", 0) == 0)
            {
                // org_id — exact match
                auto orgId = GetOptionalStringClaim(payload, "org_id");
                if (!orgId.has_value())
                {
                    throw IdTokenValidationException(
                        "Organization Id (org_id) claim must be a string present in the ID token");
                }
                if (orgId.value() != expectedOrg)
                {
                    std::ostringstream msg;
                    msg << "Organization Id (org_id) claim value mismatch in the ID token; expected ("
                        << expectedOrg << "), found (" << orgId.value() << ")";
                    throw IdTokenValidationException(msg.str());
                }
            }
            else
            {
                // org_name — compare against lowercased expected value
                auto orgName = GetOptionalStringClaim(payload, "org_name");
                if (!orgName.has_value())
                {
                    throw IdTokenValidationException(
                        "Organization Name (org_name) claim must be a string present in the ID token");
                }
                std::string expectedLower = expectedOrg;
                std::transform(expectedLower.begin(), expectedLower.end(),
                               expectedLower.begin(), ::tolower);
                if (orgName.value() != expectedLower)
                {
                    std::ostringstream msg;
                    msg << "Organization Name (org_name) claim value mismatch in the ID token; expected ("
                        << expectedOrg << "), found (" << orgName.value() << ")";
                    throw IdTokenValidationException(msg.str());
                }
            }
        }

        // All validations passed — return the decoded payload to the caller if requested
        if (outPayload != nullptr)
        {
            *outPayload = payload;
        }
    }

} // namespace auth0_flutter
