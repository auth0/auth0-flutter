/**
 * @file logout_web_auth_request_handler.cpp
 * @brief Implementation of LogoutWebAuthRequestHandler
 */

#include "logout_web_auth_request_handler.h"
#include "../../oauth_helpers.h"
#include "../../url_utils.h"
#include "../../windows_utils.h"
#include <windows.h>
#include <sstream>
#include <thread>

namespace auth0_flutter
{

    /**
     * @brief Builds the Auth0 logout URL with required parameters
     *
     * The logout URL follows the Auth0 logout endpoint specification:
     * https://{domain}/v2/logout
     *
     * Query parameters:
     * - federated: If true, also logs out from the identity provider
     * - returnTo: URL to redirect after logout completes
     * - client_id: Auth0 application client ID
     *
     * All parameters are properly percent-encoded for URL safety.
     *
     * @param domain Auth0 tenant domain
     * @param clientId Auth0 application client ID
     * @param returnTo URL to redirect after logout
     * @param federated Whether to perform federated logout
     * @return Logout URL as string with properly encoded parameters
     */
    static std::string BuildLogoutUrl(
        const std::string &domain,
        const std::string &clientId,
        const std::string &returnTo,
        bool federated)
    {
        std::ostringstream url;

        // Base logout endpoint with encoded domain
        url << "https://" << urlEncode(domain) << "/v2/logout";

        // Add federated parameter if requested
        // This will also log the user out from their identity provider
        if (federated)
        {
            url << "?federated";
        }

        // Determine query parameter separator
        char separator = federated ? '&' : '?';

        // Add returnTo URL if provided (with proper encoding)
        if (!returnTo.empty())
        {
            url << separator << "returnTo=" << urlEncode(returnTo);
            separator = '&';
        }

        // Add client_id (required by Auth0) with proper encoding
        url << separator << "client_id=" << urlEncode(clientId);

        return url.str();
    }

    /**
     * @brief Handles the webAuth#logout method call
     *
     * Process:
     * 1. Extract and validate required parameters (account)
     * 2. Extract optional parameters (returnTo, federated)
     * 3. Build logout URL with all parameters
     * 4. Open system default browser with logout URL
     * 5. Wait for browser to redirect back to the returnTo URI
     * 6. Bring Flutter window back to foreground
     * 7. Return success to Dart (always — browser-side failures are ignored)
     *
     * @param arguments Map containing configuration from Flutter
     * @param result Callback to return success/error to Flutter
     */
    void LogoutWebAuthRequestHandler::handle(
        const flutter::EncodableMap *arguments,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        if (!arguments)
        {
            result->Error("bad_args", "Expected a map as arguments");
            return;
        }

        // Extract "account" map containing clientId and domain
        auto accountIt = arguments->find(flutter::EncodableValue("_account"));
        if (accountIt == arguments->end())
        {
            result->Error("bad_args", "Missing '_account' key");
            return;
        }

        const auto *accountMap = std::get_if<flutter::EncodableMap>(&accountIt->second);
        if (!accountMap)
        {
            result->Error("bad_args", "'_account' is not a map");
            return;
        }

        // Extract required Auth0 configuration
        std::string clientId;
        std::string domain;

        if (auto it = accountMap->find(flutter::EncodableValue("clientId"));
            it != accountMap->end())
        {
            if (auto s = std::get_if<std::string>(&it->second))
            {
                clientId = *s;
            }
            else
            {
                result->Error("bad_args", "'clientId' must be a string");
                return;
            }
        }

        if (auto it = accountMap->find(flutter::EncodableValue("domain"));
            it != accountMap->end())
        {
            if (auto s = std::get_if<std::string>(&it->second))
            {
                domain = *s;
            }
            else
            {
                result->Error("bad_args", "'domain' must be a string");
                return;
            }
        }

        // Validate required parameters
        if (clientId.empty() || domain.empty())
        {
            result->Error("bad_args", "clientId and domain are required");
            return;
        }

        // Extract returnTo URL (default: "auth0flutter://callback")
        std::string returnTo = "auth0flutter://callback";
        auto returnToIt = arguments->find(flutter::EncodableValue("returnTo"));
        if (returnToIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&returnToIt->second))
            {
                returnTo = *s;
            }
        }

        // Extract federated flag (default: false)
        bool federated = false;
        auto fedIt = arguments->find(flutter::EncodableValue("federated"));
        if (fedIt != arguments->end())
        {
            if (auto b = std::get_if<bool>(&fedIt->second))
            {
                federated = *b;
            }
        }

        // Build logout URL with all parameters
        std::string logoutUrl = BuildLogoutUrl(domain, clientId, returnTo, federated);

        std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> sharedResult(result.release());

        pplx::create_task([sharedResult, logoutUrl, returnTo]()
        {
            // Open logout URL in system default browser.
            std::wstring urlW(logoutUrl.begin(), logoutUrl.end());
            ShellExecuteW(NULL, L"open", urlW.c_str(), NULL, NULL, SW_SHOWNORMAL);

            // Wait for the browser to redirect back to the returnTo URI.
            waitForLogoutCallback(returnTo);

            BringFlutterWindowToFront();
            sharedResult->Success();
        });
    }

} // namespace auth0_flutter