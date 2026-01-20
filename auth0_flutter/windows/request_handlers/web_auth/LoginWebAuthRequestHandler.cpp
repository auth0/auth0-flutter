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

#include <windows.h>
#include <sstream>
#include <stdexcept>
#include <array>
#include <iomanip>
#include <thread>

// OpenSSL for PKCE
#include <openssl/sha.h>
#include <openssl/rand.h>

#include <cpprest/json.h>

namespace auth0_flutter
{

    // Forward declarations of helper functions (defined in auth0_flutter_plugin.cpp)
    extern std::string base64UrlEncode(const std::vector<unsigned char> &data);
    extern std::string generateCodeVerifier();
    extern std::string generateCodeChallenge(const std::string &verifier);
    extern std::string waitForAuthCode_CustomScheme(const std::string &expectedRedirectBase, int timeoutSeconds);
    extern void BringFlutterWindowToFront();
    extern void DebugPrint(const std::string &msg);

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

        try
        {
            // Step 1: Generate PKCE parameters for secure OAuth flow
            // PKCE prevents authorization code interception attacks
            std::string codeVerifier = generateCodeVerifier();
            std::string codeChallenge = generateCodeChallenge(codeVerifier);

            DebugPrint("codeVerifier = " + codeVerifier);
            DebugPrint("codeChallenge = " + codeChallenge);

            // Step 2: Build OAuth 2.0 authorization URL
            // Uses authorization code flow with PKCE
            std::ostringstream authUrl;
            authUrl << "https://" << domain << "/authorize?"
                    << "response_type=code"
                    << "&client_id=" << clientId
                    << "&redirect_uri=" << redirectUri
                    << "&scope=" << scopeStr
                    << "&code_challenge=" << codeChallenge
                    << "&code_challenge_method=S256";

            // Step 3: Open system default browser for user authentication
            // User will authenticate with Auth0 in their browser
            ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

            // Step 4: Wait for OAuth callback containing authorization code
            // Timeout: 180 seconds (3 minutes)
            std::string code = waitForAuthCode_CustomScheme(redirectUri, 180);

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
