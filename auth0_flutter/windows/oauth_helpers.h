/**
 * @file oauth_helpers.h
 * @brief OAuth 2.0 and PKCE helper functions
 */

#pragma once

#include <string>
#include <vector>
#include <pplx/pplxtasks.h>

namespace auth0_flutter
{

    /**
     * @brief Percent-encode a string for safe inclusion in a URL query parameter
     *
     * Leaves alphanumeric characters and the unreserved characters - _ . ~ unchanged
     * and percent-encodes everything else (RFC 3986).
     */
    std::string urlEncode(const std::string &str);

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
     * @brief Result of waiting for OAuth callback
     */
    struct OAuthCallbackResult
    {
        bool success;                          // True if authorization code received
        std::string code;                      // Authorization code (empty if failed)
        std::string error;                     // OAuth error code (e.g., "access_denied")
        std::string errorDescription;          // Human-readable error description
        bool timedOut;                         // True if timeout occurred (no callback received)
    };

    /**
     * @brief The fixed redirect URI registered with Auth0 for the Windows plugin.
     *
     * Sent as redirect_uri in the authorization request and used as the expected
     * prefix when waiting for the OAuth callback. The app always listens on this
     * URI — no other callback URL is accepted.
     */
    inline constexpr const char *kDefaultRedirectUri = "auth0flutter://callback";

    /**
     * @brief Wait for OAuth callback with authorization code (custom scheme flow)
     *
     * Polls the PLUGIN_STARTUP_URL environment variable for the OAuth callback URL.
     * Only callbacks whose URL starts with kDefaultRedirectUri ("auth0flutter://callback")
     * are accepted.
     *
     * @param timeoutSeconds Maximum time to wait for callback (default: 180 seconds)
     * @param expectedState  Expected state parameter for CSRF validation (optional)
     * @return OAuthCallbackResult with authorization code or error details
     */
    OAuthCallbackResult waitForAuthCode_CustomScheme(
        int timeoutSeconds = 180,
        const std::string &expectedState = "",
        pplx::cancellation_token ct = pplx::cancellation_token::none());

} // namespace auth0_flutter
