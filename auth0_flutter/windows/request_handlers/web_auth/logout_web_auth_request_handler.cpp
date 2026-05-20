/**
 * @file logout_web_auth_request_handler.cpp
 * @brief Implementation of LogoutWebAuthRequestHandler
 */

#include "logout_web_auth_request_handler.h"
#include "../../oauth_helpers.h"
#include "../../url_utils.h"
#include "../../windows_utils.h"
#include <windows.h>
#include <mutex>
#include <sstream>
#include <thread>

namespace auth0_flutter
{

    // Build Auth0 logout URL (https://{domain}/v2/logout) with query parameters.
    static std::string BuildLogoutUrl(
        const std::string &domainUrl,
        const std::string &clientId,
        const std::string &returnTo,
        bool federated)
    {
        std::ostringstream url;

        // Append base logout endpoint to domain URL
        url << domainUrl << "v2/logout";

        // Append ?federated to URL if federated logout requested
        if (federated)
        {
            url << "?federated";
        }

        // Determine first separator: ? if no federated param, & if federated param present
        char separator = federated ? '&' : '?';

        // If returnTo provided, append returnTo parameter with URL encoding
        if (!returnTo.empty())
        {
            url << separator << "returnTo=" << urlEncode(returnTo);
            // Update separator to & for subsequent parameters
            separator = '&';
        }

        // Append client_id parameter (required by Auth0) with URL encoding
        url << separator << "client_id=" << urlEncode(clientId);

        // Return complete logout URL string
        return url.str();
    }

    // Handle webAuth#logout method call from Flutter.
    void LogoutWebAuthRequestHandler::handle(
        const flutter::EncodableMap *arguments,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        // Return error if arguments pointer is null
        if (!arguments)
        {
            result->Error("bad_args", "Expected a map as arguments");
            return;
        }

        // Find "_account" key in arguments map
        auto accountIt = arguments->find(flutter::EncodableValue("_account"));
        // Return error if "_account" key not found
        if (accountIt == arguments->end())
        {
            result->Error("bad_args", "Missing '_account' key");
            return;
        }

        // Extract account map from EncodableValue; return error if not a map
        const auto *accountMap = std::get_if<flutter::EncodableMap>(&accountIt->second);
        if (!accountMap)
        {
            result->Error("bad_args", "'_account' is not a map");
            return;
        }

        // Initialize clientId and domain strings (required fields)
        std::string clientId;
        std::string domain;

        // Extract clientId from account map
        if (auto it = accountMap->find(flutter::EncodableValue("clientId"));
            it != accountMap->end())
        {
            // Get string pointer from EncodableValue; return error if not a string
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

        // Extract domain from account map
        if (auto it = accountMap->find(flutter::EncodableValue("domain"));
            it != accountMap->end())
        {
            // Get string pointer from EncodableValue; return error if not a string
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

        // Return error if required parameters are empty
        if (clientId.empty() || domain.empty())
        {
            result->Error("bad_args", "clientId and domain are required");
            return;
        }

        // Initialize appCustomURL to default redirect URI
        std::string appCustomURL = kDefaultRedirectUri;
        // Find appCustomURL in arguments (optional, overrides default)
        auto appActivationIt = arguments->find(flutter::EncodableValue("appCustomURL"));
        if (appActivationIt != arguments->end())
        {
            // Use provided appCustomURL if non-empty
            if (auto s = std::get_if<std::string>(&appActivationIt->second);
                s && !s->empty())
            {
                appCustomURL = *s;
            }
        }

        // Initialize returnTo to appCustomURL (will be sent to Auth0 for post-logout redirect)
        std::string returnTo = appCustomURL;
        // Find returnTo in arguments (optional, overrides default)
        auto returnToIt = arguments->find(flutter::EncodableValue("returnTo"));
        if (returnToIt != arguments->end())
        {
            // Use provided returnTo if non-empty
            if (auto s = std::get_if<std::string>(&returnToIt->second);
                s && !s->empty())
            {
                returnTo = *s;
            }
        }

        // Initialize federated to false (default: no federated logout)
        bool federated = false;
        // Find federated in arguments (optional)
        auto fedIt = arguments->find(flutter::EncodableValue("federated"));
        if (fedIt != arguments->end())
        {
            // Use provided federated value if present
            if (auto b = std::get_if<bool>(&fedIt->second))
            {
                federated = *b;
            }
        }

        // Build complete logout URL with all parameters
        std::string logoutUrl = BuildLogoutUrl(httpsUrl(domain), clientId, returnTo, federated);

        // Create new cancellation token for this logout task
        pplx::cancellation_token token = pplx::cancellation_token::none();
        {
            // Lock cancellation token source during update
            std::lock_guard<std::mutex> lock(_cts_mutex);
            // Cancel any existing logout task
            _cts.cancel();
            // Create new token source for this logout task
            _cts = pplx::cancellation_token_source{};
            // Get cancellation token from new source
            token = _cts.get_token();
        }

        // Convert unique_ptr to shared_ptr so it's safe to pass to async task
        std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> sharedResult(result.release());

        // Capture ui_task_runner_ by value to avoid holding a dangling `this` pointer
        // if the handler is destroyed while the background task is still running.
        auto taskRunner = ui_task_runner_;

        pplx::create_task([taskRunner, sharedResult, logoutUrl, appCustomURL, token]()
        {
            try
            {
                // Convert logout URL to wide-char string
                std::wstring urlW(logoutUrl.begin(), logoutUrl.end());
                // Execute on UI thread: open URL in system default browser
                taskRunner([urlW]() {
                    ShellExecuteW(NULL, L"open", urlW.c_str(), NULL, NULL, SW_SHOWNORMAL);
                });

                // Wait for browser redirect to appCustomURL with 300-second timeout
                waitForLogoutCallback(appCustomURL, 300, token);

                // If task was not canceled, bring window to front and return success on UI thread
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult]() {
                        BringFlutterWindowToFront();
                        sharedResult->Success();
                    });
                }
            }
            // Catch task cancellation (engine shutdown or subsequent handle() call)
            catch (const pplx::task_canceled &)
            {
                // Exit silently; result is no longer valid after cancellation
            }
            // Catch any other exceptions thrown during logout process
            catch (const std::exception &e)
            {
                // If task not canceled, report error on UI thread
                if (!token.is_canceled())
                {
                    // Capture exception message as string for async lambda
                    taskRunner([sharedResult, msg = std::string(e.what())]() {
                        sharedResult->Error("LOGOUT_FAILED", msg);
                    });
                }
            }
        });
    }

} // namespace auth0_flutter