/**
 * @file oauth_helpers.h
 * @brief OAuth 2.0 and PKCE helper functions
 */

#pragma once

#include <string>
#include <vector>

namespace auth0_flutter
{

    /**
     * @brief Base64 URL-safe encode without padding
     *
     * Encodes binary data to base64 URL-safe format as required by OAuth 2.0 PKCE.
     */
    std::string base64UrlEncode(const std::vector<unsigned char> &data);

    /**
     * @brief Generate PKCE code verifier
     *
     * Creates a cryptographically random 32-byte value and encodes it as a
     * base64 URL-safe string.
     */
    std::string generateCodeVerifier();

    /**
     * @brief Generate code challenge from verifier for PKCE flow
     *
     * Creates the code challenge by hashing the verifier with SHA256 and
     * encoding the result as base64 URL-safe.
     */
    std::string generateCodeChallenge(const std::string &verifier);

    /**
     * @brief Wait for OAuth callback with authorization code (custom scheme flow)
     *
     * Polls the PLUGIN_STARTUP_URL environment variable for the OAuth redirect URI.
     */
    std::string waitForAuthCode_CustomScheme(
        const std::string &expectedRedirectBase,
        int timeoutSeconds = 180,
        const std::string &expectedState = "");

    /**
     * @brief Wait for OAuth callback with authorization code (HTTP listener flow)
     *
     * Starts a local HTTP server to listen for OAuth callback.
     */
    std::string waitForAuthCode(const std::string &redirectUri);

} // namespace auth0_flutter
