/**
 * @file auth0_flutter_plugin.cpp
 * @brief Main plugin implementation for Auth0 Flutter Windows
 *
 * This file contains the main plugin class and helper utilities for WebAuth operations.
 * The plugin follows a handler pattern similar to the Android and iOS implementations,
 * delegating method calls to specialized handlers.
 *
 * Architecture:
 * - Auth0FlutterPlugin: Main plugin class, registers with Flutter engine
 * - Auth0FlutterWebAuthMethodCallHandler: Routes method calls to appropriate handlers
 * - LoginWebAuthRequestHandler: Handles webAuth#login
 * - LogoutWebAuthRequestHandler: Handles webAuth#logout
 *
 * Helper utilities:
 * - PKCE functions for OAuth security
 * - Base64 URL encoding
 * - Custom scheme callback handling
 * - Window management
 */

#define _CRT_SECURE_NO_WARNINGS
#define _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
#define NOMINMAX
#include "auth0_flutter_plugin.h"
// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <thread>
#include <stdexcept>
#include <array>
#include <iomanip>

// OpenSSL for PKCE
#include <openssl/sha.h>
#include <openssl/rand.h>

// cpprestsdk
#include <cpprest/http_listener.h>
#include <cpprest/uri.h>
#include <cpprest/http_client.h>
#include <cpprest/json.h>

#include "auth0_client.h"
#include "time_util.h"
#include "credentials.h"
#include "user_identity.h"
#include "user_profile.h"
#include "jwt_util.h"

// WebAuth handlers
#include "Auth0FlutterWebAuthMethodCallHandler.h"
#include "request_handlers/web_auth/LoginWebAuthRequestHandler.h"
#include "request_handlers/web_auth/LogoutWebAuthRequestHandler.h"

using namespace web;
using namespace web::http;
using namespace web::http::client;
using namespace web::http::experimental::listener;

namespace auth0_flutter
{

    // -------------------- PKCE Helpers --------------------

    /**
     * @brief Base64 URL-safe encode without padding
     *
     * Encodes binary data to base64 URL-safe format as required by OAuth 2.0 PKCE.
     *
     * Transformations:
     * - '+' → '-'
     * - '/' → '_'
     * - Removes padding '='
     *
     * @param data Binary data to encode
     * @return Base64 URL-safe encoded string
     */
    std::string base64UrlEncode(const std::vector<unsigned char> &data)
    {
        static const char *b64chars =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        std::string result;
        size_t i = 0;
        unsigned char a3[3];
        unsigned char a4[4];

        for (size_t pos = 0; pos < data.size();)
        {
            int len = 0;
            for (i = 0; i < 3; i++)
            {
                if (pos < data.size())
                {
                    a3[i] = data[pos++];
                    len++;
                }
                else
                {
                    a3[i] = 0;
                }
            }

            a4[0] = (a3[0] & 0xfc) >> 2;
            a4[1] = ((a3[0] & 0x03) << 4) + ((a3[1] & 0xf0) >> 4);
            a4[2] = ((a3[1] & 0x0f) << 2) + ((a3[2] & 0xc0) >> 6);
            a4[3] = a3[2] & 0x3f;

            for (i = 0; i < 4; i++)
            {
                if (i <= (size_t)(len + 0))
                {
                    result += b64chars[a4[i]];
                }
                else
                {
                    result += '=';
                }
            }
        }

        // Make it URL-safe
        for (auto &c : result)
        {
            if (c == '+')
                c = '-';
            if (c == '/')
                c = '_';
        }

        // Strip padding '='
        while (!result.empty() && result.back() == '=')
        {
            result.pop_back();
        }

        return result;
    }

    /**
     * @brief Brings the Flutter window to the foreground
     *
     * After the user completes authentication in the browser, this function
     * brings the Flutter app window back to focus. Uses Windows-specific APIs
     * to bypass foreground lock restrictions.
     *
     * Technique:
     * 1. Restore window if minimized
     * 2. Attach input threads to bypass foreground restrictions
     * 3. Set window as foreground and focused
     */
    void BringFlutterWindowToFront()
    {
        HWND hwnd = GetActiveWindow();

        if (!hwnd)
        {
            hwnd = GetForegroundWindow();
        }

        if (!hwnd)
            return;

        // Restore if minimized
        if (IsIconic(hwnd))
        {
            ShowWindow(hwnd, SW_RESTORE);
        }

        // Required trick to bypass foreground lock
        DWORD currentThread = GetCurrentThreadId();
        DWORD foregroundThread = GetWindowThreadProcessId(GetForegroundWindow(), NULL);

        AttachThreadInput(foregroundThread, currentThread, TRUE);

        SetForegroundWindow(hwnd);
        SetFocus(hwnd);
        SetActiveWindow(hwnd);

        AttachThreadInput(foregroundThread, currentThread, FALSE);
    }

    /**
     * @brief Generate random code verifier for PKCE flow
     *
     * Creates a cryptographically random 32-byte value and encodes it as a
     * base64 URL-safe string. This is the code verifier used in OAuth 2.0 PKCE.
     *
     * @return Base64 URL-safe encoded random string (43 characters)
     * @throws std::runtime_error if random generation fails
     */
    std::string generateCodeVerifier()
    {
        std::vector<unsigned char> buffer(32);
        if (RAND_bytes(buffer.data(), static_cast<int>(buffer.size())) != 1)
        {
            throw std::runtime_error("Failed to generate random bytes");
        }
        return base64UrlEncode(buffer);
    }

    /**
     * @brief Generate code challenge from verifier for PKCE flow
     *
     * Creates the code challenge by hashing the verifier with SHA256 and
     * encoding the result as base64 URL-safe. This challenge is sent in the
     * authorization request, and the verifier is sent during token exchange.
     *
     * Formula: BASE64URL(SHA256(ASCII(verifier)))
     *
     * @param verifier The code verifier string
     * @return Base64 URL-safe encoded SHA256 hash of the verifier
     */
    std::string generateCodeChallenge(const std::string &verifier)
    {
        unsigned char hash[SHA256_DIGEST_LENGTH];
        SHA256(reinterpret_cast<const unsigned char *>(verifier.data()),
               verifier.size(),
               hash);

        std::vector<unsigned char> digest(hash, hash + SHA256_DIGEST_LENGTH);
        return base64UrlEncode(digest);
    }

    // ---------- Helpers: URL-decode, safe query parse, and waitForAuthCode (custom scheme) ----------

    /**
     * @brief Decodes a URL-encoded string
     *
     * Handles percent-encoding (%XX) and plus-to-space conversion.
     *
     * @param str URL-encoded string
     * @return Decoded string
     */
    static std::string UrlDecode(const std::string &str)
    {
        std::string out;
        out.reserve(str.size());
        for (size_t i = 0; i < str.size(); ++i)
        {
            char c = str[i];
            if (c == '%')
            {
                if (i + 2 < str.size())
                {
                    std::string hex = str.substr(i + 1, 2);
                    char decoded = (char)strtol(hex.c_str(), nullptr, 16);
                    out.push_back(decoded);
                    i += 2;
                }
                // else malformed percent-encoding: skip
            }
            else if (c == '+')
            {
                out.push_back(' ');
            }
            else
            {
                out.push_back(c);
            }
        }
        return out;
    }

    /**
     * @brief Safely parses URL query parameters
     *
     * Parses a query string (without leading '?') into a map of key-value pairs.
     * Handles URL-decoded keys and values.
     *
     * @param query Query string (e.g., "code=ABC&state=XYZ")
     * @return Map of decoded parameter names to values
     */
    static std::map<std::string, std::string> SafeParseQuery(const std::string &query)
    {
        std::map<std::string, std::string> params;
        size_t start = 0;
        while (start < query.size())
        {
            size_t eq = query.find('=', start);
            if (eq == std::string::npos)
            {
                break; // no more key=value pairs
            }
            std::string key = query.substr(start, eq - start);
            size_t amp = query.find('&', eq + 1);
            std::string value;
            if (amp == std::string::npos)
            {
                value = query.substr(eq + 1);
                start = query.size();
            }
            else
            {
                value = query.substr(eq + 1, amp - (eq + 1));
                start = amp + 1;
            }
            params[UrlDecode(key)] = UrlDecode(value);
        }
        return params;
    }

    /**
     * @brief Converts wide string (wchar_t) to UTF-8
     *
     * Safely converts Windows wide strings to UTF-8 encoded strings.
     * Used for converting environment variable values from Windows API.
     *
     * @param wstr Wide string to convert
     * @return UTF-8 encoded string
     */
    static std::string WideToUtf8(const std::wstring &wstr)
    {
        if (wstr.empty())
            return {};
        int size_needed = ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(),
                                                (int)wstr.size(), nullptr, 0, nullptr, nullptr);
        if (size_needed <= 0)
            return {};
        std::string str(size_needed, 0);
        ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(), (int)wstr.size(), &str[0], size_needed, nullptr, nullptr);
        return str;
    }

    /**
     * @brief Wait for OAuth callback via custom scheme (environment variable polling)
     *
     * Polls the PLUGIN_STARTUP_URL environment variable for the OAuth redirect URI.
     * The Windows runner sets this variable when the app is launched via custom scheme
     * (auth0flutter://callback?code=...).
     *
     * Process:
     * 1. Poll environment variable every 200ms
     * 2. When found, clear the variable and parse the URI
     * 3. Extract the 'code' parameter from query string
     * 4. Return authorization code or empty string on timeout/error
     *
     * @param expectedRedirectBase Expected redirect URI prefix (e.g., "auth0flutter://callback")
     * @param timeoutSeconds Maximum time to wait (default: 180 seconds / 3 minutes)
     * @return Authorization code on success, empty string on timeout/error
     *
     * Example stored value: auth0flutter://callback?code=AUTH_CODE&state=xyz
     */
    static std::string waitForAuthCode_CustomScheme(const std::string &expectedRedirectBase, int timeoutSeconds = 180)
    {
        const int sleepMs = 200;
        int elapsed = 0;
        auto readAndClearEnv = []() -> std::string
        {
            // Ask Windows how many wchar_t characters are needed (including null)
            DWORD bufSize = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", NULL, 0);
            if (bufSize == 0)
                return std::string();

            std::vector<wchar_t> buf(bufSize);
            DWORD ret = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", buf.data(), bufSize);
            if (ret == 0 || ret >= bufSize)
            {
                return std::string();
            }

            // Clear it so it's not consumed twice
            SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");

            // Convert wide -> UTF-8 safely
            std::wstring wstr(buf.data(), ret);
            return WideToUtf8(wstr);
        };

        while (elapsed < timeoutSeconds * 1000)
        {
            std::string uri = readAndClearEnv();
            if (!uri.empty())
            {
                //    DebugPrint("Received startup URI: " + uri);
                // Optionally: verify prefix matches expectedRedirectBase (e.g. "auth0flutter://callback")
                if (!expectedRedirectBase.empty())
                {
                    if (uri.rfind(expectedRedirectBase, 0) != 0)
                    {
                        //       DebugPrint("Warning: received URI does not start with expected redirect base");
                        // continue — but still try to parse if present
                    }
                }
                // find query
                auto qpos = uri.find('?');
                if (qpos == std::string::npos)
                {
                    return std::string(); // no query params
                }
                std::string query = uri.substr(qpos + 1);
                auto params = SafeParseQuery(query);
                auto it = params.find("code");
                if (it != params.end())
                {
                    return it->second;
                }
                else
                {
                    // maybe error param present
                    if (params.find("error") != params.end())
                    {
                        //  DebugPrint("OAuth returned error: " + params["error"]);
                        return std::string();
                    }
                }
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(sleepMs));
            elapsed += sleepMs;
        }

        // timeout
        return std::string();
    }

    // -------------------- Local Redirect Listener --------------------

    /**
     * @brief Wait for OAuth callback via local HTTP listener (alternative approach)
     *
     * Creates a local HTTP server to receive the OAuth redirect. This is an
     * alternative to the custom scheme approach, but requires localhost redirect URIs.
     *
     * Note: Currently not used in favor of custom scheme approach.
     *
     * @param redirectUri The redirect URI (e.g., "http://localhost:8080/callback")
     * @return Authorization code from the callback
     */
    std::string waitForAuthCode(const std::string &redirectUri)
    {
        uri u(utility::conversions::to_string_t(redirectUri));
        http_listener listener(u);

        std::string authCode;

        listener.support(methods::GET, [&](http_request request)
                         {
    auto queries = uri::split_query(request.request_uri().query());
    auto it = queries.find(U("code"));
    if (it != queries.end()) {
      authCode = utility::conversions::to_utf8string(it->second);
    }

    request.reply(status_codes::OK,
                  U("Login successful! You may close this window.")); });

        listener.open().wait();

        while (authCode.empty())
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        listener.close().wait();
        return authCode;
    }

    // -------------------- Plugin Impl --------------------

    /**
     * @brief Registers the plugin with the Flutter engine
     *
     * Sets up the WebAuth method channel and initializes the plugin with
     * all required handlers. This follows the same channel name and architecture
     * as Android and iOS implementations.
     *
     * Channel: "auth0.com/auth0_flutter/web_auth"
     * Methods supported:
     * - webAuth#login: Handled by LoginWebAuthRequestHandler
     * - webAuth#logout: Handled by LogoutWebAuthRequestHandler
     *
     * @param registrar The Flutter plugin registrar
     */
    void Auth0FlutterPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "auth0.com/auth0_flutter/web_auth",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<Auth0FlutterPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));
    }

    /**
     * @brief Constructor - initializes the plugin with WebAuth handlers
     *
     * Creates and registers all WebAuth request handlers following the
     * strategy pattern used in Android and iOS implementations.
     */
    Auth0FlutterPlugin::Auth0FlutterPlugin()
    {
        // Initialize WebAuth method call handler with all request handlers
        std::vector<std::unique_ptr<WebAuthRequestHandler>> handlers;
        handlers.push_back(std::make_unique<LoginWebAuthRequestHandler>());
        handlers.push_back(std::make_unique<LogoutWebAuthRequestHandler>());

        webAuthCallHandler_ = std::make_unique<Auth0FlutterWebAuthMethodCallHandler>(
            std::move(handlers));
    }

    Auth0FlutterPlugin::~Auth0FlutterPlugin() {}

    /**
     * @brief Debug logging utility
     *
     * Prints debug messages to the Visual Studio Output window using
     * OutputDebugString. Visible when debugging in Visual Studio.
     *
     * @param msg Message to log
     */
    void DebugPrint(const std::string &msg)
    {
        OutputDebugStringA((msg + "\n").c_str());
    }

    /**
     * @brief Builds Auth0 logout URL (helper function, now moved to LogoutWebAuthRequestHandler)
     *
     * This function is deprecated and kept for backward compatibility.
     * New code should use LogoutWebAuthRequestHandler instead.
     *
     * @deprecated Use LogoutWebAuthRequestHandler::BuildLogoutUrl instead
     */
    static std::ostringstream BuildLogoutUrl(
        const std::string &domain,
        const std::string &clientId,
        const std::string &returnTo,
        bool federated)
    {
        std::ostringstream url;

        url << "https://" << domain << "/v2/logout";

        // Swift: v2/logout?federated
        if (federated)
        {
            url << "?federated";
        }

        // Append query params
        char separator = federated ? '&' : '?';

        if (!returnTo.empty())
        {
            url << separator << "returnTo=" << returnTo;
            separator = '&';
        }

        url << separator << "client_id=" << clientId;

        return url;
    }

    /**
     * @brief Handles method calls from Flutter
     *
     * Delegates all method calls to the appropriate handler. This implementation
     * follows the same pattern as Android and iOS, using a handler-based architecture
     * for clean separation of concerns.
     *
     * All WebAuth methods (login, logout) are handled by webAuthCallHandler_,
     * which routes to specialized handlers based on the method name.
     *
     * @param method_call The method call from Flutter
     * @param result Callback to return results to Flutter
     */
    void Auth0FlutterPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        // Delegate all method calls to the WebAuth handler
        // The handler will route to appropriate specialized handlers based on method name
        webAuthCallHandler_->HandleMethodCall(method_call, std::move(result));
    }

} // namespace auth0_flutter