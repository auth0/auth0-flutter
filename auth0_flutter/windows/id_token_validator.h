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
        std::string issuer;              // Expected issuer (iss claim)
        std::string audience;            // Expected audience/client ID (aud claim)
        int leeway = 60;                 // Clock skew leeway in seconds (default: 60)
        std::optional<int> maxAge;       // Maximum authentication age in seconds (optional)
        std::optional<std::string> nonce; // Expected nonce value (optional)
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
     * Performs the following validations:
     * 1. Issuer (iss) claim matches expected issuer
     * 2. Audience (aud) claim contains the client ID
     * 3. Token has not expired (exp claim, with leeway)
     * 4. Token was issued at a valid time (iat claim)
     * 5. If maxAge specified, validates auth_time claim
     * 6. If nonce provided, validates nonce claim
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
