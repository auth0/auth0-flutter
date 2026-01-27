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

            std::ostringstream oss;
            bool first = true;
            for (const auto &v : *scopeList)
            {
                const auto *s = std::get_if<std::string>(&v);
                if (!s)
                {
                    result->Error("bad_args", "Each scope must be a String");
                    return;
                }
                if (!first)
                    oss << " ";
                oss << *s;
                first = false;
            }

            scopeStr = oss.str();
        }

        // Extract redirect URI (default: "auth0flutter://callback")
        std::string redirectUri = "auth0flutter://callback";
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
            ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

            // Step 4: Wait for OAuth callback containing authorization code with state validation
            // Timeout: 180 seconds (3 minutes)
            // State parameter is validated to prevent CSRF attacks
            std::string code = waitForAuthCode_CustomScheme(redirectUri, 180, state);

            // Step 5: Bring Flutter window back to foreground
            BringFlutterWindowToFront();

            if (code.empty())
            {
                result->Error("auth_failed", "Failed to receive authorization code (timeout or user cancelled)");
                return;
            }

            // Step 6: Exchange authorization code for tokens
            // Sends code verifier to prove we initiated the flow (PKCE validation)
            Auth0Client client(domain, clientId);
            Credentials creds = client.ExchangeCodeForTokens(redirectUri, code, codeVerifier);

            // Step 7: Build response map with credentials
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

            // Step 8: Decode ID token JWT to extract user profile
            web::json::value payload_json = DecodeJwtPayload(creds.idToken);
            auto ev = JsonToEncodable(payload_json);
            auto payload_map = std::get<flutter::EncodableMap>(ev);
            UserProfile user = UserProfile::DeserializeUserProfile(payload_map);
            response[flutter::EncodableValue("userProfile")] = flutter::EncodableValue(user.ToMap());

            // Step 9: Return success with credentials
            result->Success(flutter::EncodableValue(response));
        }
        catch (const std::exception &e)
        {
            // Handle any errors during the authentication flow
            result->Error("auth_failed", e.what());
        }
    }

} // namespace auth0_flutter
