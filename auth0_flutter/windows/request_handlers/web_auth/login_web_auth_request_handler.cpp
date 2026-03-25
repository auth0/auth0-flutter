/**
 * @file login_web_auth_request_handler.cpp
 * @brief Implementation of LoginWebAuthRequestHandler
 */

#include "login_web_auth_request_handler.h"
#include "../../auth0_client.h"
#include "../../credentials.h"
#include "../../user_profile.h"
#include "../../jwt_util.h"
#include "../../time_util.h"
#include "../../oauth_helpers.h"
#include "../../url_utils.h"
#include "../../windows_utils.h"
#include "../../id_token_validator.h"
#include "../../authentication_error.h"

#include <windows.h>
#include <set>
#include <sstream>
#include <stdexcept>
#include <array>
#include <iomanip>
#include <map>

#include <cpprest/json.h>

namespace auth0_flutter
{

    /**
     * @brief Handles the webAuth#login method call
     *
     * Process:
     * 1. Extract and validate required parameters (account, scopes)
     * 2. Generate PKCE parameters for secure OAuth flow
     * 3. Build authorization URL with all required OAuth parameters
     * 4. Open system default browser with authorization URL
     * 5. Wait for OAuth callback containing authorization code
     * 6. Bring Flutter window back to foreground
     * 7. Exchange authorization code for tokens using Auth0 token endpoint
     * 8. Parse tokens and extract user profile from ID token
     * 9. Return credentials map to Flutter
     *
     * @param arguments Map containing configuration from Flutter
     * @param result Callback to return success/error to Flutter
     */
    void LoginWebAuthRequestHandler::handle(
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

        std::set<std::string> scopeSet = {"openid"};

        auto scopesIt = arguments->find(flutter::EncodableValue("scopes"));
        if (scopesIt == arguments->end())
        {
            // No scopes key — use platform default
            scopeSet = {"openid", "offline_access", "profile", "email"};
        }
        else
        {
            const auto *scopeList = std::get_if<flutter::EncodableList>(&scopesIt->second);
            if (!scopeList)
            {
                result->Error("bad_args", "'scopes' must be a list");
                return;
            }

            for (const auto &v : *scopeList)
            {
                const auto *s = std::get_if<std::string>(&v);
                if (!s)
                {
                    result->Error("bad_args", "Each scope must be a String");
                    return;
                }
                scopeSet.insert(*s);
            }
        }

        std::string scopeStr;
        for (const auto &s : scopeSet)
        {
            if (!scopeStr.empty()) scopeStr += ' ';
            scopeStr += s;
        }


        // Extract appActivationURL — the custom-scheme URL the Windows app listens on
        // to receive the OAuth callback from the browser (or an intermediary server).
        // Defaults to kDefaultRedirectUri ("auth0flutter://callback").
        std::string appActivationURL = kDefaultRedirectUri;
        auto appActivationIt = arguments->find(flutter::EncodableValue("appActivationURL"));
        if (appActivationIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&appActivationIt->second);
                s && !s->empty())
            {
                appActivationURL = *s;
            }
        }

        // Extract redirect URI — the redirect_uri sent to Auth0 in the authorization URL.
        // Defaults to appActivationURL when not provided.  When using an intermediary
        // server (Option B), the server URL is the redirectUrl while the app still listens
        // on appActivationURL.
        std::string redirectUri = appActivationURL;
        auto redirectIt = arguments->find(flutter::EncodableValue("redirectUrl"));
        if (redirectIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&redirectIt->second);
                s && !s->empty())
            {
                redirectUri = *s;
            }
        }

        // Extract optional parameters
        std::string audience;
        auto audienceIt = arguments->find(flutter::EncodableValue("audience"));
        if (audienceIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&audienceIt->second))
            {
                audience = *s;
            }
        }

        std::string organizationId;
        auto orgIt = arguments->find(flutter::EncodableValue("organizationId"));
        if (orgIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&orgIt->second))
            {
                organizationId = *s;
            }
        }

        std::string invitationUrl;
        auto inviteIt = arguments->find(flutter::EncodableValue("invitationUrl"));
        if (inviteIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&inviteIt->second))
            {
                invitationUrl = *s;
            }
        }

        std::string state = generateCodeVerifier();
        std::string nonce = generateCodeVerifier();

        auto parametersIt = arguments->find(flutter::EncodableValue("parameters"));
        const flutter::EncodableMap *parametersMap = nullptr;
        if (parametersIt != arguments->end())
        {
            parametersMap = std::get_if<flutter::EncodableMap>(&parametersIt->second);
        }

        if (parametersMap)
        {
            if (auto it = parametersMap->find(flutter::EncodableValue("state"));
                it != parametersMap->end())
            {
                if (auto s = std::get_if<std::string>(&it->second); s && !s->empty())
                {
                    state = *s;
                }
            }
            if (auto it = parametersMap->find(flutter::EncodableValue("nonce"));
                it != parametersMap->end())
            {
                if (auto s = std::get_if<std::string>(&it->second); s && !s->empty())
                {
                    nonce = *s;
                }
            }
        }

        static const std::set<std::string> kReservedParams = {
            "response_type", "client_id", "redirect_uri", "scope",
            "code_challenge", "code_challenge_method", "state", "nonce",
            "audience", "organization", "invitation", "max_age"
        };

        std::map<std::string, std::string> extraParams;
        if (parametersMap)
        {
            for (const auto &kv : *parametersMap)
            {
                const auto *k = std::get_if<std::string>(&kv.first);
                const auto *v = std::get_if<std::string>(&kv.second);
                if (k && v && kReservedParams.find(*k) == kReservedParams.end())
                    extraParams[*k] = *v;
            }
        }

        int authTimeoutSeconds = 300;
        auto timeoutIt = arguments->find(flutter::EncodableValue("authTimeoutSeconds"));
        if (timeoutIt != arguments->end())
        {
            if (auto i = std::get_if<int>(&timeoutIt->second))
            {
                if (*i <= 0)
                {
                    result->Error("bad_args", "'authTimeoutSeconds' must be a positive integer");
                    return;
                }
                if (*i > 3600)
                {
                    result->Error("bad_args", "'authTimeoutSeconds' exceeds the maximum of 3600 seconds");
                    return;
                }
                authTimeoutSeconds = *i;
            }
            else
            {
                result->Error("bad_args", "'authTimeoutSeconds' must be an integer");
                return;
            }
        }

        // Extract ID token validation configuration
        int leeway = 60; // Default: 60 seconds
        auto leewayIt = arguments->find(flutter::EncodableValue("leeway"));
        if (leewayIt != arguments->end())
        {
            if (auto i = std::get_if<int>(&leewayIt->second))
            {
                leeway = *i;
            }
        }

        std::optional<int> maxAge;
        auto maxAgeIt = arguments->find(flutter::EncodableValue("maxAge"));
        if (maxAgeIt != arguments->end())
        {
            if (auto i = std::get_if<int>(&maxAgeIt->second))
            {
                maxAge = *i;
            }
        }

        // Normalize domain to a proper HTTPS base URL
        // Used as the default issuer and to derive the JWKS endpoint.
        std::string domainUrl = httpsUrl(domain);

        std::string issuer = domainUrl;
        auto issuerIt = arguments->find(flutter::EncodableValue("issuer"));
        if (issuerIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&issuerIt->second); s && !s->empty())
            {
                issuer = httpsUrl(*s);
            }
        }

        // Cancel any previously running login task so a second call to handle()
        // does not leave a stale task that still holds a reference to the old
        // (now-replaced) MethodResult.
        // pplx::cancellation_token has a private default constructor; it must
        // be obtained from a cancellation_token_source or from ::none().
        pplx::cancellation_token token = pplx::cancellation_token::none();
        {
            std::lock_guard<std::mutex> lock(_cts_mutex);
            _cts.cancel();
            _cts = pplx::cancellation_token_source{};
            token = _cts.get_token();
        }

        std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> sharedResult(result.release());

        auto taskRunner = ui_task_runner_;

        // Run authentication on a cancellable pplx task to avoid blocking the
        // Flutter UI thread.  The cancellation token lets the destructor (or a
        // subsequent handle() call) abort a running flow cleanly.
        pplx::create_task([taskRunner, sharedResult,
                           clientId, domain, domainUrl, scopeStr, redirectUri, appActivationURL, audience, organizationId, invitationUrl, authTimeoutSeconds, leeway, maxAge, state, nonce, issuer, token, extraParams]()
                          {
            try
            {
                // Step 1: Generate PKCE parameters for secure OAuth flow
                // PKCE prevents authorization code interception attacks
                std::string codeVerifier = generateCodeVerifier();
                std::string codeChallenge = generateCodeChallenge(codeVerifier);

                // Parse invitation URL to extract organization and invitation query parameters.
                std::string resolvedOrganizationId = organizationId;
                std::string invitationId;
                if (!invitationUrl.empty())
                {
                    auto qpos = invitationUrl.find('?');
                    auto queryString = (qpos != std::string::npos)
                                           ? invitationUrl.substr(qpos + 1)
                                           : std::string{};
                    auto invParams = SafeParseQuery(queryString);
                    auto orgIt = invParams.find("organization");
                    auto invIt = invParams.find("invitation");
                    if (orgIt == invParams.end() || invIt == invParams.end() ||
                        orgIt->second.empty() || invIt->second.empty())
                    {
                        if (!token.is_canceled())
                        {
                            taskRunner([sharedResult, invitationUrl]() {
                                sharedResult->Error("INVALID_INVITATION_URL",
                                    "Invalid invitation URL: " + invitationUrl);
                            });
                        }
                        return;
                    }
                    resolvedOrganizationId = orgIt->second;
                    invitationId = invIt->second;
                }

            // Step 2: Build OAuth 2.0 authorization URL with properly encoded parameters
            // Uses authorization code flow with PKCE, state for CSRF, and nonce for OIDC replay protection
            std::ostringstream authUrl;
            authUrl << domainUrl << "authorize?"
                    << "response_type=code"
                    << "&client_id=" << urlEncode(clientId)
                    << "&redirect_uri=" << urlEncode(redirectUri)
                    << "&scope=" << urlEncode(scopeStr)
                    << "&code_challenge=" << urlEncode(codeChallenge)
                    << "&code_challenge_method=S256"
                    << "&state=" << urlEncode(state)
                    << "&nonce=" << urlEncode(nonce);

            // Add optional parameters if provided
            if (!audience.empty())
            {
                authUrl << "&audience=" << urlEncode(audience);
            }

            if (!resolvedOrganizationId.empty())
            {
                authUrl << "&organization=" << urlEncode(resolvedOrganizationId);
            }

            if (!invitationId.empty())
            {
                authUrl << "&invitation=" << urlEncode(invitationId);
            }

            if (maxAge.has_value())
            {
                authUrl << "&max_age=" << maxAge.value();
            }

            for (const auto &kv : extraParams)
            {
                authUrl << "&" << urlEncode(kv.first) << "=" << urlEncode(kv.second);
            }

            // Step 3: Open system default browser for user authentication.
            // Must run on the UI thread (ShellExecuteW uses COM STA).
            // Fire-and-forget: the background thread proceeds immediately to wait
            // for the OAuth callback while the UI thread opens the browser.
            {

                std::string urlStr = authUrl.str();
                std::wstring urlW(urlStr.begin(), urlStr.end());
                taskRunner([urlW]() {
                    ShellExecuteW(NULL, L"open", urlW.c_str(), NULL, NULL, SW_SHOWNORMAL);
                });
            }

            // Step 4: Wait for OAuth callback containing authorization code with state validation
            // State parameter is validated to prevent CSRF attacks
            OAuthCallbackResult callbackResult = waitForAuthCode_CustomScheme(authTimeoutSeconds, state, token, appActivationURL);

            if (token.is_canceled())
            {
                return;
            }

            // Step 5: Bring Flutter window back to foreground (must be on UI thread).
            taskRunner([]() { BringFlutterWindowToFront(); });

            // Handle callback result
            if (!callbackResult.success)
            {
                // Distinguish between different error scenarios
                if (callbackResult.timedOut)
                {
                    // User likely closed the browser without completing authentication
                    // Return USER_CANCELLED error code for consistency across platforms
                    if (!token.is_canceled())
                    {
                        taskRunner([sharedResult]() {
                            sharedResult->Error("USER_CANCELLED",
                                "The user cancelled the Web Auth operation.");
                        });
                    }
                    return;
                }
                else if (callbackResult.error == "state_mismatch")
                {
                    // State parameter validation failed (CSRF protection)
                    // This is a security issue - use specific error code
                    if (!token.is_canceled())
                    {
                        taskRunner([sharedResult, callbackResult]() {
                            sharedResult->Error("INVALID_STATE",
                                callbackResult.errorDescription);
                        });
                    }
                    return;
                }
                else if (!callbackResult.error.empty())
                {
                    // OAuth error received in callback (e.g., access_denied, invalid_scope, etc.)
                    // Return the OAuth error code and description directly for cross-platform consistency

                    // Return OAuth error code and description directly.
                    std::string message = callbackResult.errorDescription.empty()
                        ? callbackResult.error
                        : callbackResult.errorDescription;
                    if (!token.is_canceled())
                    {
                        taskRunner([sharedResult, error = callbackResult.error, message]() {
                            sharedResult->Error(error, message);
                        });
                    }
                    return;
                }
                else
                {
                    // Invalid callback - no code and no error
                    if (!token.is_canceled())
                    {
                        taskRunner([sharedResult]() {
                            sharedResult->Error("NO_AUTHORIZATION_CODE",
                                "The callback URL is missing the authorization code.");
                        });
                    }
                    return;
                }
            }

            std::string code = callbackResult.code;

            // Step 6: Exchange authorization code for tokens
            // Sends code verifier to prove we initiated the flow (PKCE validation)
            Credentials creds;
            try
            {
                Auth0Client client(domain, clientId);
                creds = client.ExchangeCodeForTokens(redirectUri, code, codeVerifier);
            }
            catch (const auth0_flutter::AuthenticationError &e)
            {
                // Token exchange failed.
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult, code = e.GetCode(), desc = e.GetDescription()]() {
                        sharedResult->Error(code, desc);
                    });
                }
                return;
            }

            // Step 7: Validate ID token (OIDC compliance)
            // This validates issuer, audience, expiration, and other critical claims
            web::json::value validatedPayload;
            try
            {
                IdTokenValidationConfig validationConfig;
                validationConfig.issuer = issuer;
                validationConfig.audience = clientId;
                validationConfig.leeway = leeway;
                validationConfig.maxAge = maxAge;
                validationConfig.nonce = nonce;
                if (!resolvedOrganizationId.empty())
                {
                    validationConfig.organization = resolvedOrganizationId;
                }

                // RS256 signature validation via the JWKS well-known endpoint.
                validationConfig.jwksUri = domainUrl + ".well-known/jwks.json";

                ValidateIdToken(creds.idToken, validationConfig, &validatedPayload);
            }
            catch (const IdTokenValidationException &e)
            {
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult, msg = std::string("The ID token validation performed after authentication failed: ") + e.what()]() {
                        sharedResult->Error("ID_TOKEN_VALIDATION_FAILED", msg);
                    });
                }
                return;
            }

            // Step 8: Build response map with credentials
            flutter::EncodableMap response;

            response[flutter::EncodableValue("accessToken")] =
                flutter::EncodableValue(creds.accessToken);

            response[flutter::EncodableValue("idToken")] =
                flutter::EncodableValue(creds.idToken);

            if (creds.refreshToken.has_value())
            {
                response[flutter::EncodableValue("refreshToken")] =
                    flutter::EncodableValue(creds.refreshToken.value());
            }

            response[flutter::EncodableValue("tokenType")] =
                flutter::EncodableValue(creds.tokenType);

            if (creds.expiresAt.has_value())
            {
                response[flutter::EncodableValue("expiresAt")] =
                    flutter::EncodableValue(ToIso8601(creds.expiresAt.value()));
            }

            // Convert scopes vector to Flutter list
            flutter::EncodableList scopes;
            for (const auto &credscope : creds.scope)
            {
                scopes.emplace_back(credscope);
            }
            response[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopes);

            // Step 9: Extract user profile from validated ID token payload
            // Use the validated payload from step 7 (already decoded and validated)
            auto ev = JsonToEncodable(validatedPayload);
            const auto *payload_map_ptr = std::get_if<flutter::EncodableMap>(&ev);
            if (!payload_map_ptr)
            {
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult]() {
                        sharedResult->Error("AUTH_FAILED",
                            "ID token payload could not be decoded as a JSON object");
                    });
                }
                return;
            }
            UserProfile user = UserProfile::DeserializeUserProfile(*payload_map_ptr);
            response[flutter::EncodableValue("userProfile")] = flutter::EncodableValue(user.ToMap());

                // Step 10: Return success with credentials (must be on UI thread).
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult, response]() {
                        sharedResult->Success(flutter::EncodableValue(response));
                    });
                }
            }
            catch (const pplx::task_canceled &)
            {
                // Cancellation was requested (engine shutdown or a subsequent
                // handle() call).  result is no longer valid — exit silently.
            }
            catch (const std::exception &e)
            {
                if (!token.is_canceled())
                {
                    taskRunner([sharedResult, msg = std::string(e.what())]() {
                        sharedResult->Error("AUTH_FAILED", msg);
                    });
                }
            } });
    }

} // namespace auth0_flutter
