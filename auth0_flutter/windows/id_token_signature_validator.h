/**
 * @file id_token_signature_validator.h
 * @brief RS256 signature validation for ID tokens using the JWKS well-known endpoint
 *
 * Mirrors the approach in Auth0.swift IDTokenSignatureValidator:
 * https://github.com/auth0/Auth0.swift/blob/feat/requestable_protocol/Auth0/IDTokenSignatureValidator.swift
 *
 * Validation steps:
 * 1. Verify the JWT header declares alg=RS256 (the only supported algorithm)
 * 2. Verify the JWT header contains a kid (Key ID)
 * 3. Fetch the JWKS from the well-known endpoint
 * 4. Locate the JWK whose kid matches the token's kid
 * 5. Reconstruct the RSA public key from the JWK (n, e)
 * 6. Verify the RS256 (SHA-256 + RSASSA-PKCS1-v1_5) signature
 */

#pragma once

#include <string>
#include "id_token_validator.h"

namespace auth0_flutter
{

    /**
     * @brief Validates the RS256 signature of an ID token against the JWKS endpoint.
     *
     * @param idToken  The raw JWT string
     * @param jwksUri  Full URL of the JWKS endpoint, e.g. "https://tenant.auth0.com/.well-known/jwks.json"
     * @throws IdTokenValidationException on any signature-related failure
     */
    void ValidateIdTokenSignature(
        const std::string &idToken,
        const std::string &jwksUri);

} // namespace auth0_flutter
