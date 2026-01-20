/**
 * @file LogoutWebAuthRequestHandler.h
 * @brief Handler for WebAuth logout method calls
 *
 * Implements the "webAuth#logout" method, which performs Auth0 logout by opening
 * the Auth0 logout endpoint in the system browser. This clears the user's session
 * and optionally performs federated logout across identity providers.
 *
 * Flow:
 * 1. Extract logout configuration parameters
 * 2. Build logout URL with returnTo and federated parameters
 * 3. Open system browser with logout URL
 * 4. Return success immediately (logout is fire-and-forget)
 */

#ifndef FLUTTER_PLUGIN_LOGOUT_WEB_AUTH_REQUEST_HANDLER_H_
#define FLUTTER_PLUGIN_LOGOUT_WEB_AUTH_REQUEST_HANDLER_H_

#include "WebAuthRequestHandler.h"

namespace auth0_flutter
{

    /**
     * @class LogoutWebAuthRequestHandler
     * @brief Handles webAuth#logout method calls from Flutter
     *
     * Configuration parameters supported:
     * - _account (required): Map containing:
     *   - clientId: Auth0 application client ID
     *   - domain: Auth0 tenant domain
     * - returnTo: URL to redirect after logout (default: "auth0flutter://callback")
     * - federated: Whether to perform federated logout (clears IdP session too)
     *
     * Logout URL format:
     * https://{domain}/v2/logout?federated&returnTo={returnTo}&client_id={clientId}
     *
     * Response:
     * - Returns null/void on success (logout is asynchronous, no callback needed)
     * - Returns error if parameters are invalid
     */
    class LogoutWebAuthRequestHandler : public WebAuthRequestHandler
    {
    public:
        LogoutWebAuthRequestHandler() = default;
        ~LogoutWebAuthRequestHandler() override = default;

        std::string method() const override
        {
            return "webAuth#logout";
        }

        void handle(
            const flutter::EncodableMap *arguments,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;
    };

} // namespace auth0_flutter

#endif // FLUTTER_PLUGIN_LOGOUT_WEB_AUTH_REQUEST_HANDLER_H_
