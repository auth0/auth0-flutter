/**
 * @file LoginWebAuthRequestHandler.h
 * @brief Handler for WebAuth login method calls
 *
 * Implements the "webAuth#login" method, which performs OAuth 2.0 authorization code flow
 * with PKCE (Proof Key for Code Exchange) for secure authentication.
 *
 * Flow:
 * 1. Generate PKCE code verifier and challenge
 * 2. Build authorization URL with required parameters
 * 3. Open system browser for user authentication
 * 4. Wait for OAuth callback with authorization code
 * 5. Exchange authorization code for tokens
 * 6. Return credentials (access token, ID token, refresh token, user profile)
 */

#ifndef FLUTTER_PLUGIN_LOGIN_WEB_AUTH_REQUEST_HANDLER_H_
#define FLUTTER_PLUGIN_LOGIN_WEB_AUTH_REQUEST_HANDLER_H_

#include "WebAuthRequestHandler.h"

namespace auth0_flutter
{

    /**
     * @class LoginWebAuthRequestHandler
     * @brief Handles webAuth#login method calls from Flutter
     *
     * Configuration parameters supported:
     * - _account (required): Map containing:
     *   - clientId: Auth0 application client ID
     *   - domain: Auth0 tenant domain
     * - scopes: List of OAuth scopes (default: ["openid", "profile", "email"])
     * - audience: API identifier for which to request tokens
     * - redirectUrl: OAuth callback URL (default: "auth0flutter://callback")
     * - organizationId: Organization ID for multi-tenant setups
     * - invitationUrl: Invitation URL for organization invites
     * - parameters: Custom parameters for Auth0 Rules/Actions
     *
     * Response structure:
     * - accessToken: OAuth 2.0 access token
     * - idToken: OpenID Connect ID token (JWT)
     * - refreshToken: Refresh token (if available)
     * - tokenType: Token type (typically "Bearer")
     * - expiresAt: ISO8601 formatted expiration timestamp
     * - scopes: List of granted scopes
     * - userProfile: Map containing user profile claims from ID token
     */
    class LoginWebAuthRequestHandler : public WebAuthRequestHandler
    {
    public:
        LoginWebAuthRequestHandler() = default;
        ~LoginWebAuthRequestHandler() override = default;

        std::string method() const override
        {
            return "webAuth#login";
        }

        void handle(
            const flutter::EncodableMap *arguments,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_LOGIN_WEB_AUTH_REQUEST_HANDLER_H_
