/**
 * @file LoginWebAuthRequestHandler.cpp
 * @brief Implementation of LoginWebAuthRequestHandler
 */

#include "LoginWebAuthRequestHandler.h"
#include "../../auth0_client.h"
#include "../../credentials.h"
#include "../../user_profile.h"
#include "../../jwt_util.h"
#include "../../time_util.h"
#include "../../oauth_helpers.h"
#include "../../windows_utils.h"
#include "../../id_token_validator.h"
#include "../../authentication_exception.h"

#include <windows.h>
#include <sstream>
#include <stdexcept>
#include <array>
#include <iomanip>
#include <thread>
#include <map>

#include <cpprest/json.h>

namespace auth0_flutter
{

    // Local URL encoding helper (kept here per design requirement)
    static std::string UrlEncode(const std::string &str)
    {
        std::ostringstream encoded;
        encoded.fill('0');
        encoded << std::hex << std::uppercase;

        for (unsigned char c : str)
        {
            // Keep alphanumeric and safe characters unchanged
            if (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~')
            {
                encoded << c;
            }
            else
            {
                // Percent-encode everything else
                encoded << '%' << std::setw(2) << static_cast<int>(c);
            }
        }

        return encoded.str();
    }

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
                DebugPrint("Added 'openid' scope to authorization request (OIDC compliance)");
            }
            else if (!hasOpenId && scopeStr.empty())
            {
                // If no scopes provided, use just "openid"
                scopeStr = "openid";
                DebugPrint("Using 'openid' scope for authorization request (OIDC compliance)");
            }
        }

        // Extract redirect URI (default: "auth0flutter://callback")
        // Default to localhost HTTP callback for better user experience
        // This displays a friendly "redirecting" page instead of leaving browser stuck
        std::string redirectUri = "http://localhost:8080/callback";
        auto redirectIt = arguments->find(flutter::EncodableValue("redirectUrl"));
        if (redirectIt != arguments->end())
        {
            if (auto s = std::get_if<std::string>(&redirectIt->second))
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
        if (parametersIt == arguments->end())
        {
            result->Error("bad_args", "Missing 'parameters' key");
            return;
        }

        const auto *parametersMap = std::get_if<flutter::EncodableMap>(&parametersIt->second);
        if (!parametersMap)
        {
            result->Error("bad_args", "'parameters' is not a map");
            return;
        }
        // Extract the actual callback URL to listen for (may differ from redirectUri sent to Auth0)
        // This is used when an intermediary server receives the Auth0 redirect and forwards to the app
        std::string actualCallbackUrl = redirectUri;
        auto callbackUrlIt = parametersMap->find(flutter::EncodableValue("actualCallbackUrl"));
        if (callbackUrlIt != parametersMap->end())
        {
            if (auto s = std::get_if<std::string>(&callbackUrlIt->second))
            {
                actualCallbackUrl = *s;
                DebugPrint("Using custom actualCallbackUrl: " + actualCallbackUrl);
            }
        }

        // Extract additional parameters map
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
                    if (key && val)
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

        // Run authentication flow in background thread to avoid blocking UI
        std::thread([
            result = std::move(result),
            clientId, domain, scopeStr, redirectUri, audience, organizationId, invitationUrl, actualCallbackUrl, additionalParams,
            leeway, maxAge, issuer
        ]() mutable {
            try
            {
                // Step 1: Generate PKCE parameters for secure OAuth flow
                // PKCE prevents authorization code interception attacks
                std::string codeVerifier = generateCodeVerifier();
                std::string codeChallenge = generateCodeChallenge(codeVerifier);

                // Generate state parameter for CSRF protection
                std::string state = generateCodeVerifier(); // Reuse code verifier generation for random state

                DebugPrint("codeVerifier = " + codeVerifier);
                DebugPrint("codeChallenge = " + codeChallenge);
                DebugPrint("state = " + state);

            // Step 2: Build OAuth 2.0 authorization URL with properly encoded parameters
            // Uses authorization code flow with PKCE and state for CSRF protection
            std::ostringstream authUrl;
            authUrl << "https://" << UrlEncode(domain) << "/authorize?"
                    << "response_type=code"
                    << "&client_id=" << UrlEncode(clientId)
                    << "&redirect_uri=" << UrlEncode(redirectUri)
                    << "&scope=" << UrlEncode(scopeStr)
                    << "&code_challenge=" << UrlEncode(codeChallenge)
                    << "&code_challenge_method=S256"
                    << "&state=" << UrlEncode(state);

            // Add optional parameters if provided
            if (!audience.empty())
            {
                authUrl << "&audience=" << UrlEncode(audience);
            }

            if (!organizationId.empty())
            {
                authUrl << "&organization=" << UrlEncode(organizationId);
            }

            if (!invitationUrl.empty())
            {
                authUrl << "&invitation=" << UrlEncode(invitationUrl);
            }

            // Add any additional custom parameters
            for (const auto &kv : additionalParams)
            {
                authUrl << "&" << UrlEncode(kv.first) << "=" << UrlEncode(kv.second);
            }

            // Step 3: Open system default browser for user authentication
            // User will authenticate with Auth0 in their browser
            DebugPrint("Opening authorize URL: " + authUrl.str());
            ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

            // Step 4: Wait for OAuth callback containing authorization code with state validation
            // Timeout: 180 seconds (3 minutes)
            // State parameter is validated to prevent CSRF attacks
            DebugPrint("Using custom scheme for callback: " + actualCallbackUrl);
            OAuthCallbackResult callbackResult = waitForAuthCode_CustomScheme(actualCallbackUrl, 180, state);

            // Step 5: Bring Flutter window back to foreground
            DebugPrint("Callback received, bringing window to front");
            BringFlutterWindowToFront();

            // Handle callback result
            if (!callbackResult.success)
            {
                // Distinguish between different error scenarios
                if (callbackResult.timedOut)
                {
                    // User likely closed the browser without completing authentication
                    // Match iOS/Android behavior: USER_CANCELLED error code
                    DebugPrint("ERROR: Timeout waiting for callback (user cancelled)");
                    result->Error("USER_CANCELLED",
                        "The user cancelled the Web Auth operation.",
                        flutter::EncodableValue());
                    return;
                }
                else if (callbackResult.error == "state_mismatch")
                {
                    // State parameter validation failed (CSRF protection)
                    // This is a security issue - use specific error code
                    DebugPrint("ERROR: State mismatch - potential CSRF attack");
                    result->Error("INVALID_STATE",
                        callbackResult.errorDescription,
                        flutter::EncodableValue());
                    return;
                }
                else if (!callbackResult.error.empty())
                {
                    // OAuth error received in callback (e.g., access_denied, invalid_scope, etc.)
                    // Return the OAuth error code and description directly, like Android/iOS
                    DebugPrint("ERROR: OAuth error - " + callbackResult.error);

                    // Build details map with error information
                    flutter::EncodableMap errorDetails;
                    errorDetails[flutter::EncodableValue("error")] = flutter::EncodableValue(callbackResult.error);
                    if (!callbackResult.errorDescription.empty())
                    {
                        errorDetails[flutter::EncodableValue("error_description")] =
                            flutter::EncodableValue(callbackResult.errorDescription);
                    }

                    // Use the OAuth error code directly as the error code
                    // This matches how Android returns exception.getCode()
                    std::string message = callbackResult.errorDescription.empty()
                        ? callbackResult.error
                        : callbackResult.errorDescription;

                    result->Error(callbackResult.error, message, flutter::EncodableValue(errorDetails));
                    return;
                }
                else
                {
                    // Invalid callback - no code and no error
                    DebugPrint("ERROR: Invalid callback - no authorization code");
                    result->Error("NO_AUTHORIZATION_CODE",
                        "The callback URL is missing the authorization code.",
                        flutter::EncodableValue());
                    return;
                }
            }

            std::string code = callbackResult.code;
            DebugPrint("Authorization code received: " + code.substr(0, 10) + "...");

            // Step 6: Exchange authorization code for tokens
            // Sends code verifier to prove we initiated the flow (PKCE validation)
            Credentials creds;
            try
            {
                DebugPrint("Exchanging code for tokens with redirect_uri: " + redirectUri);
                Auth0Client client(domain, clientId);
                creds = client.ExchangeCodeForTokens(redirectUri, code, codeVerifier);
                DebugPrint("Token exchange successful");
            }
            catch (const auth0_flutter::AuthenticationException &e)
            {
                // Token exchange failed - return error details
                DebugPrint(std::string("Token exchange failed: ") + e.GetCode() + " - " + e.GetDescription());

                // Build error details map with additional information
                flutter::EncodableMap errorDetails;
                errorDetails[flutter::EncodableValue("_statusCode")] = flutter::EncodableValue(e.GetStatusCode());

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

                // Return error with code, description, and details (matching Android pattern)
                result->Error(
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
                // Note: nonce validation would go here if nonce was sent in authorization request

                DebugPrint("Validating ID token with issuer: " + issuer);
                ValidateIdToken(creds.idToken, validationConfig, &validatedPayload);
                DebugPrint("ID token validation successful");
            }
            catch (const IdTokenValidationException &e)
            {
                DebugPrint(std::string("ID token validation failed: ") + e.what());
                // Match iOS error code: ID_TOKEN_VALIDATION_FAILED
                result->Error("ID_TOKEN_VALIDATION_FAILED",
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

                // Step 10: Return success with credentials
                result->Success(flutter::EncodableValue(response));
            }
            catch (const std::exception &e)
            {
                // Handle any errors during the authentication flow
                result->Error("auth_failed", e.what());
            }
        }).detach(); // Detach thread to run independently
    }

} // namespace auth0_flutter
