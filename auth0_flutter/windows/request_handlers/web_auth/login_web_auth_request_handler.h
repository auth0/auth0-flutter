/**
 * @file login_web_auth_request_handler.h
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

#include "web_auth_request_handler.h"
#include <pplx/pplxtasks.h>
#include <functional>
#include <mutex>

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
        LoginWebAuthRequestHandler()
            : ui_task_runner_([](std::function<void()> task){ task(); }) {}

        explicit LoginWebAuthRequestHandler(std::function<void(std::function<void()>)> post_ui_task)
            : ui_task_runner_(std::move(post_ui_task)) {}

        // Cancels any in-flight pplx task so the task body stops
        // before it can touch the (now-destroyed) MethodResult.
        ~LoginWebAuthRequestHandler() override {
            std::lock_guard<std::mutex> lock(_cts_mutex);
            _cts.cancel();
        }

        std::string method() const override
        {
            return "webAuth#login";
        }

        void handle(
            const flutter::EncodableMap *arguments,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

    private:
        std::function<void(std::function<void()>)> ui_task_runner_;
        std::mutex _cts_mutex;
        pplx::cancellation_token_source _cts;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_LOGIN_WEB_AUTH_REQUEST_HANDLER_H_
