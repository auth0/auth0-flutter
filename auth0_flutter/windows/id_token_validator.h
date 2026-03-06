/**
 * @file id_token_validator.h
 * @brief ID Token validation for OIDC compliance
 *
 * Implements ID token validation as per OpenID Connect specification:
 * https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
 */

#pragma once

#include <string>
#include <optional>
#include <stdexcept>
#include <cpprest/json.h>

namespace auth0_flutter
{

    /**
     * @brief Configuration for ID token validation
     */
    struct IdTokenValidationConfig
    {
        std::string issuer;               // Expected issuer (iss claim)
        std::string audience;             // Expected audience/client ID (aud claim)
        int leeway = 60;                  // Clock skew leeway in seconds (default: 60)
        std::optional<int> maxAge;        // Maximum authentication age in seconds (optional)
        std::optional<std::string> nonce; // Expected nonce value (optional)

        // Organization identifier or name.
        // If the value starts with "org_" it is treated as an org_id and the
        // org_id claim is validated (exact match).
        // Otherwise it is treated as an org_name and the org_name claim is
        std::optional<std::string> organization;

        // When set, RS256 signature validation is performed against this JWKS endpoint.
        // Typically "https://{domain}/.well-known/jwks.json".
        // Leave empty to skip signature validation (for tests / offline use).
        std::optional<std::string> jwksUri;
    };

    /**
     * @brief Exception thrown when ID token validation fails
     */
    class IdTokenValidationException : public std::runtime_error
    {
    public:
        explicit IdTokenValidationException(const std::string &message)
            : std::runtime_error(message) {}
    };

    /**
     * @brief Validates an ID token according to OIDC specification
     *
     * Performs the following validations (mirrors Auth0.swift IDTokenValidator):
     * 1.  Issuer (iss) — present and matches expected issuer
     * 2.  Subject (sub) — present and non-empty
     * 3.  Audience (aud) — present and contains the client ID
     * 4.  Expiration (exp) — token has not expired (leeway applied)
     * 5.  Issued At (iat) — claim is present
     * 6.  Nonce (nonce) — if provided, present and matching
     * 7.  Authorized Party (azp) — if aud is multi-value, present and equals client ID
     * 8.  Auth Time (auth_time) — if maxAge provided, present and within maxAge + leeway
     * 9.  Organization (org_id/org_name) — if organization provided:
     *       starts with "org_" → org_id exact match
     *       otherwise          → org_name case-insensitive match
     *
     * @param idToken The JWT ID token to validate
     * @param config Validation configuration
     * @param payload Output parameter - the decoded JWT payload (optional)
     * @throws IdTokenValidationException if validation fails
     */
    void ValidateIdToken(
        const std::string &idToken,
        const IdTokenValidationConfig &config,
        web::json::value *payload = nullptr);

} // namespace auth0_flutter
