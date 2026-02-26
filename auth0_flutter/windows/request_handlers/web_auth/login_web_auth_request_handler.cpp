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
#include <sstream>
#include <stdexcept>
#include <array>
#include <iomanip>
#include <map>
#include <set>

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
            clientId = std::get<std::string>(it->second);
        }

        if (auto it = accountMap->find(flutter::EncodableValue("domain"));
            it != accountMap->end())
        {
            domain = std::get<std::string>(it->second);
        }

        // Validate required parameters
        if (clientId.empty() || domain.empty())
        {
            result->Error("bad_args", "clientId and domain are required");
            return;
        }

        // Extract scopes (default: "openid profile email")
        std::string scopeStr = "openid profile email";

        auto scopesIt = arguments->find(flutter::EncodableValue("scopes"));
        if (scopesIt != arguments->end())
        {
            const auto *scopeList = std::get_if<flutter::EncodableList>(&scopesIt->second);
            if (!scopeList)
            {
                result->Error("bad_args", "'scopes' must be a List<String>");
                return;
            }

            // Build scope string from provided list
            std::ostringstream oss;
            bool first = true;
            bool hasOpenId = false;

            for (const auto &v : *scopeList)
            {
                const auto *s = std::get_if<std::string>(&v);
                if (!s)
                {
                    result->Error("bad_args", "Each scope must be a String");
                    return;
                }

                // Check if "openid" scope is present
                if (*s == "openid")
                {
                    hasOpenId = true;
                }

                if (!first)
                    oss << " ";
                oss << *s;
                first = false;
            }

            scopeStr = oss.str();

            // Ensure "openid" scope is always present (OIDC compliance)
            // The "openid" scope is required to get an ID token
            if (!hasOpenId && !scopeStr.empty())
            {
                scopeStr = "openid " + scopeStr;
            }
            else if (!hasOpenId && scopeStr.empty())
            {
                // If no scopes provided, use just "openid"
                scopeStr = "openid";
            }
        }

        // Extract redirect URI – defaults to the fixed custom-scheme callback URL.
        // The app always listens on kDefaultRedirectUri ("auth0flutter://callback"),
        // so any value provided here must be registered with Auth0 accordingly.
        std::string redirectUri = kDefaultRedirectUri;
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

        auto parametersIt = arguments->find(flutter::EncodableValue("parameters"));
        const flutter::EncodableMap *parametersMap = nullptr;
        if (parametersIt != arguments->end())
        {
            parametersMap = std::get_if<flutter::EncodableMap>(&parametersIt->second);
        }

        // Extract authentication timeout in seconds (default: 180 seconds / 3 minutes)
        int authTimeoutSeconds = 180;
        if (parametersMap)
        {
            auto timeoutIt = parametersMap->find(flutter::EncodableValue("authTimeoutSeconds"));
            if (timeoutIt != parametersMap->end())
            {
                if (auto s = std::get_if<std::string>(&timeoutIt->second))
                {
                    try
                    {
                        authTimeoutSeconds = std::stoi(*s);
                    }
                    catch (const std::exception &)
                    {
                        // If parsing fails, use default value
                    }
                }
            }
        }

        // Extract additional parameters to append to the authorize URL.
        // Internal plugin parameters (authTimeoutSeconds) are consumed above
        // and must NOT be forwarded to the authorization server.
        static const std::set<std::string> kInternalParams = {"authTimeoutSeconds"};
        std::map<std::string, std::string> additionalParams;
        auto paramsIt = arguments->find(flutter::EncodableValue("parameters"));
        if (paramsIt != arguments->end())
        {
            const auto *paramsMap = std::get_if<flutter::EncodableMap>(&paramsIt->second);
            if (paramsMap)
            {
                for (const auto &kv : *paramsMap)
                {
                    const auto *key = std::get_if<std::string>(&kv.first);
                    const auto *val = std::get_if<std::string>(&kv.second);
                    if (key && val && kInternalParams.find(*key) == kInternalParams.end())
                    {
                        additionalParams[*key] = *val;
                    }
                }
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

        std::string issuer = "https://" + domain + "/";
        auto issuerIt = arguments->find(flutter::EncodableValue("issuer"));
        if (issuerIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&issuerIt->second))
            {
                issuer = *s;
            }
        }

        // Cancel any previously running login task so a second call to handle()
        // does not leave a stale task that still holds a reference to the old
        // (now-replaced) MethodResult.
        _cts.cancel();
        _cts = pplx::cancellation_token_source{};
        auto token = _cts.get_token();

        // MSVC PPL's create_task requires the functor to be CopyConstructible.
        // std::unique_ptr is move-only, so transfer ownership to shared_ptr first.
        // All synchronous argument validation above has already run at this point.
        std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> sharedResult(result.release());

        // Run authentication on a cancellable pplx task to avoid blocking the
        // Flutter UI thread.  The cancellation token lets the destructor (or a
        // subsequent handle() call) abort a running flow cleanly.
        pplx::create_task([
            sharedResult,
            clientId, domain, scopeStr, redirectUri, audience, organizationId, invitationUrl, authTimeoutSeconds, additionalParams,
            leeway, maxAge, issuer, token
        ]() {
            try
            {
                // Step 1: Generate PKCE parameters for secure OAuth flow
                // PKCE prevents authorization code interception attacks
                std::string codeVerifier = generateCodeVerifier();
                std::string codeChallenge = generateCodeChallenge(codeVerifier);

                // Generate state (CSRF protection) and nonce (OIDC replay protection)
                std::string state = generateCodeVerifier();
                std::string nonce = generateCodeVerifier();

                // Parse invitation URL to extract organization and invitation query parameters.
                // Mirrors Swift/Android SDK behavior: the raw URL is never forwarded as-is;
                // only the extracted param values are sent to the authorization server.
                std::string resolvedOrganizationId = organizationId;
                std::string invitationId;
                if (!invitationUrl.empty())
                {
                    auto qpos = invitationUrl.find('?');
                    if (qpos != std::string::npos)
                    {
                        auto invParams = SafeParseQuery(invitationUrl.substr(qpos + 1));
                        auto orgIt = invParams.find("organization");
                        auto invIt = invParams.find("invitation");
                        if (orgIt == invParams.end() || invIt == invParams.end())
                        {
                            sharedResult->Error("INVALID_INVITATION_URL",
                                "Invalid invitation URL: missing organization or invitation parameters",
                                flutter::EncodableValue());
                            return;
                        }
                        resolvedOrganizationId = orgIt->second;
                        invitationId = invIt->second;
                    }
                }

            // Step 2: Build OAuth 2.0 authorization URL with properly encoded parameters
            // Uses authorization code flow with PKCE, state for CSRF, and nonce for OIDC replay protection
            std::ostringstream authUrl;
            authUrl << "https://" << urlEncode(domain) << "/authorize?"
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

            // Add any additional custom parameters
            for (const auto &kv : additionalParams)
            {
                authUrl << "&" << urlEncode(kv.first) << "=" << urlEncode(kv.second);
            }

            // Step 3: Open system default browser for user authentication
            // User will authenticate with Auth0 in their browser
            ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

            // Step 4: Wait for OAuth callback containing authorization code with state validation
            // State parameter is validated to prevent CSRF attacks
            OAuthCallbackResult callbackResult = waitForAuthCode_CustomScheme(authTimeoutSeconds, state, token);

            // If cancellation was requested after the callback arrived (e.g. the
            // destructor was called while the token exchange is in progress), bail
            // out now so we never call result on a potentially-destroyed MethodResult.
            if (token.is_canceled())
            {
                return;
            }

            // Step 5: Bring Flutter window back to foreground
            BringFlutterWindowToFront();

            // Handle callback result
            if (!callbackResult.success)
            {
                // Distinguish between different error scenarios
                if (callbackResult.timedOut)
                {
                    // User likely closed the browser without completing authentication
                    // Return USER_CANCELLED error code for consistency across platforms
                    sharedResult->Error("USER_CANCELLED",
                        "The user cancelled the Web Auth operation.",
                        flutter::EncodableValue());
                    return;
                }
                else if (callbackResult.error == "state_mismatch")
                {
                    // State parameter validation failed (CSRF protection)
                    // This is a security issue - use specific error code
                    sharedResult->Error("INVALID_STATE",
                        callbackResult.errorDescription,
                        flutter::EncodableValue());
                    return;
                }
                else if (!callbackResult.error.empty())
                {
                    // OAuth error received in callback (e.g., access_denied, invalid_scope, etc.)
                    // Return the OAuth error code and description directly for cross-platform consistency

                    // Build details map with error information
                    flutter::EncodableMap errorDetails;
                    errorDetails[flutter::EncodableValue("error")] = flutter::EncodableValue(callbackResult.error);
                    if (!callbackResult.errorDescription.empty())
                    {
                        errorDetails[flutter::EncodableValue("error_description")] =
                            flutter::EncodableValue(callbackResult.errorDescription);
                    }

                    // Use the OAuth error code directly as the error code
                    // for consistency with other platform implementations
                    std::string message = callbackResult.errorDescription.empty()
                        ? callbackResult.error
                        : callbackResult.errorDescription;

                    sharedResult->Error(callbackResult.error, message, flutter::EncodableValue(errorDetails));
                    return;
                }
                else
                {
                    // Invalid callback - no code and no error
                    sharedResult->Error("NO_AUTHORIZATION_CODE",
                        "The callback URL is missing the authorization code.",
                        flutter::EncodableValue());
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
                // Token exchange failed - return error details for cross-platform consistency

                // Build error details map with additional information
                flutter::EncodableMap errorDetails;
                errorDetails[flutter::EncodableValue("_statusCode")] = flutter::EncodableValue(e.GetStatusCode());

                // Add error flags for detailed error classification
                flutter::EncodableMap errorFlags;
                errorFlags[flutter::EncodableValue("isInvalidCredentials")] = flutter::EncodableValue(e.IsInvalidCredentials());
                errorFlags[flutter::EncodableValue("isAccessDenied")] = flutter::EncodableValue(e.IsAccessDenied());
                errorFlags[flutter::EncodableValue("isMultifactorRequired")] = flutter::EncodableValue(e.IsMultifactorRequired());
                errorFlags[flutter::EncodableValue("isNetworkError")] = flutter::EncodableValue(e.IsNetworkError());
                errorFlags[flutter::EncodableValue("isRefreshTokenDeleted")] = flutter::EncodableValue(e.IsRefreshTokenDeleted());
                errorFlags[flutter::EncodableValue("isPasswordNotStrongEnough")] = flutter::EncodableValue(e.IsPasswordNotStrongEnough());
                errorFlags[flutter::EncodableValue("isPasswordAlreadyUsed")] = flutter::EncodableValue(e.IsPasswordAlreadyUsed());
                errorFlags[flutter::EncodableValue("isPasswordLeaked")] = flutter::EncodableValue(e.IsPasswordLeaked());
                errorFlags[flutter::EncodableValue("isTooManyAttempts")] = flutter::EncodableValue(e.IsTooManyAttempts());
                errorFlags[flutter::EncodableValue("isLoginRequired")] = flutter::EncodableValue(e.IsLoginRequired());
                errorFlags[flutter::EncodableValue("isRuleError")] = flutter::EncodableValue(e.IsRuleError());
                errorDetails[flutter::EncodableValue("_errorFlags")] = flutter::EncodableValue(errorFlags);

                // Add MFA token if present (for multifactor authentication flows)
                std::string mfaToken = e.GetValue("mfa_token");
                if (!mfaToken.empty())
                {
                    errorDetails[flutter::EncodableValue("mfa_token")] = flutter::EncodableValue(mfaToken);
                }

                // Return error with code, description, and details
                sharedResult->Error(
                    e.GetCode(),
                    e.GetDescription(),
                    flutter::EncodableValue(errorDetails));
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

                // RS256 signature validation via the JWKS well-known endpoint.
                // Derived from the issuer URL: issuer already has a trailing "/".
                validationConfig.jwksUri = issuer + ".well-known/jwks.json";

                ValidateIdToken(creds.idToken, validationConfig, &validatedPayload);
            }
            catch (const IdTokenValidationException &e)
            {
                // Return ID_TOKEN_VALIDATION_FAILED error code
                sharedResult->Error("ID_TOKEN_VALIDATION_FAILED",
                    std::string("The ID token validation performed after authentication failed: ") + e.what(),
                    flutter::EncodableValue());
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
            auto payload_map = std::get<flutter::EncodableMap>(ev);
            UserProfile user = UserProfile::DeserializeUserProfile(payload_map);
            response[flutter::EncodableValue("userProfile")] = flutter::EncodableValue(user.ToMap());

                // Step 10: Return success with credentials.
                // Guard against the narrow race where cancellation is signalled
                // between the polling loop returning and this call.
                if (!token.is_canceled())
                {
                    sharedResult->Success(flutter::EncodableValue(response));
                }
            }
            catch (const pplx::task_canceled &)
            {
                // Cancellation was requested (engine shutdown or a subsequent
                // handle() call).  result is no longer valid — exit silently.
            }
            catch (const std::exception &e)
            {
                // Handle any unexpected errors during the authentication flow.
                // Guard against the rare race where cancellation fires after the
                // polling loop completes but before the result is delivered.
                if (!token.is_canceled())
                {
                    sharedResult->Error("auth_failed", e.what());
                }
            }
        });
    }

} // namespace auth0_flutter
