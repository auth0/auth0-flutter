/**
 * @file oauth_helpers.cpp
 * @brief Implementation of OAuth 2.0 and PKCE helper functions
 */

#include "oauth_helpers.h"
#include "url_utils.h"
#include "windows_utils.h"

#include <windows.h>
#include <thread>
#include <chrono>
#include <stdexcept>
#include <vector>
#include <sstream>

// OpenSSL for PKCE
#include <openssl/sha.h>
#include <openssl/rand.h>

// cpprestsdk for HTTP listener
#include <cpprest/http_listener.h>
#include <cpprest/uri.h>

using namespace web;
using namespace web::http;
using namespace web::http::experimental::listener;

namespace auth0_flutter
{

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

    std::string generateCodeVerifier()
    {
        std::vector<unsigned char> buffer(32);
        if (RAND_bytes(buffer.data(), static_cast<int>(buffer.size())) != 1)
        {
            throw std::runtime_error("Failed to generate random bytes");
        }
        return base64UrlEncode(buffer);
    }

    std::string generateCodeChallenge(const std::string &verifier)
    {
        unsigned char hash[SHA256_DIGEST_LENGTH];
        SHA256(reinterpret_cast<const unsigned char *>(verifier.data()),
               verifier.size(),
               hash);

        std::vector<unsigned char> digest(hash, hash + SHA256_DIGEST_LENGTH);
        return base64UrlEncode(digest);
    }

    std::string waitForAuthCode_CustomScheme(
        const std::string &expectedRedirectBase,
        int timeoutSeconds,
        const std::string &expectedState)
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
                // Optionally: verify prefix matches expectedRedirectBase
                if (!expectedRedirectBase.empty())
                {
                    if (uri.rfind(expectedRedirectBase, 0) != 0)
                    {
                        // Warning: received URI does not start with expected redirect base
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

                // Validate state parameter if expected state is provided (CSRF protection)
                if (!expectedState.empty())
                {
                    auto stateIt = params.find("state");
                    if (stateIt == params.end() || stateIt->second != expectedState)
                    {
                        DebugPrint("State validation failed: expected '" + expectedState +
                                   "', received '" + (stateIt != params.end() ? stateIt->second : "(missing)") + "'");
                        return std::string(); // State mismatch - potential CSRF attack
                    }
                }

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

    std::string waitForAuthCode(
        const std::string &redirectUri,
        int timeoutSeconds,
        const std::string &expectedState)
    {
        uri u(utility::conversions::to_string_t(redirectUri));
        http_listener listener(u);

        std::string authCode;
        bool callbackReceived = false;

        listener.support(methods::GET, [&](http_request request)
                         {
            auto queries = uri::split_query(request.request_uri().query());

            // Validate state parameter if provided (CSRF protection)
            if (!expectedState.empty())
            {
                auto stateIt = queries.find(U("state"));
                std::string receivedState;
                if (stateIt != queries.end())
                {
                    receivedState = utility::conversions::to_utf8string(stateIt->second);
                }

                if (receivedState != expectedState)
                {
                    DebugPrint("State validation failed in HTTP listener: expected '" +
                               expectedState + "', received '" + receivedState + "'");

                    // Return error page for state mismatch
                    std::string errorHtml = R"html(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Error</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 400px;
        }
        .icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        h1 {
            color: #d32f2f;
            margin: 0 0 16px 0;
            font-size: 24px;
        }
        p {
            color: #666;
            margin: 0 0 24px 0;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">⚠️</div>
        <h1>Authentication Error</h1>
        <p>Invalid authentication state detected. Please try again.</p>
    </div>
</body>
</html>
)html";
                    request.reply(status_codes::BadRequest,
                                  utility::conversions::to_string_t(errorHtml),
                                  U("text/html"));
                    callbackReceived = true;
                    return;
                }
            }

            // Extract authorization code
            auto it = queries.find(U("code"));
            if (it != queries.end()) {
                authCode = utility::conversions::to_utf8string(it->second);
            }

            // Check for error parameter
            auto errorIt = queries.find(U("error"));
            if (errorIt != queries.end())
            {
                std::string errorCode = utility::conversions::to_utf8string(errorIt->second);
                std::string errorDescription = "Authentication failed";

                auto errorDescIt = queries.find(U("error_description"));
                if (errorDescIt != queries.end())
                {
                    errorDescription = utility::conversions::to_utf8string(errorDescIt->second);
                }

                DebugPrint("OAuth error received: " + errorCode + " - " + errorDescription);

                // Return error page
                std::string errorHtml = R"html(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Failed</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 400px;
        }
        .icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        h1 {
            color: #d32f2f;
            margin: 0 0 16px 0;
            font-size: 24px;
        }
        p {
            color: #666;
            margin: 0 0 24px 0;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">❌</div>
        <h1>Authentication Failed</h1>
        <p>)html" + errorDescription + R"html(</p>
        <p style="font-size: 14px; color: #999;">You can close this window.</p>
    </div>
</body>
</html>
)html";
                request.reply(status_codes::OK,
                              utility::conversions::to_string_t(errorHtml),
                              U("text/html"));
                callbackReceived = true;
                return;
            }

            // Success response with auto-close
            std::string successHtml = R"html(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Authentication Successful</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 400px;
        }
        .icon {
            font-size: 64px;
            margin-bottom: 20px;
            animation: checkmark 0.5s ease-in-out;
        }
        @keyframes checkmark {
            0% { transform: scale(0); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        h1 {
            color: #2e7d32;
            margin: 0 0 16px 0;
            font-size: 24px;
        }
        p {
            color: #666;
            margin: 0 0 8px 0;
            line-height: 1.5;
        }
        .countdown {
            font-size: 14px;
            color: #999;
            margin-top: 16px;
        }
        .spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 8px;
            vertical-align: middle;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
    <script>
        // Auto-close after 3 seconds
        let countdown = 3;
        function updateCountdown() {
            const countdownEl = document.getElementById('countdown');
            if (countdown > 0) {
                countdownEl.textContent = countdown;
                countdown--;
                setTimeout(updateCountdown, 1000);
            } else {
                window.close();
                // If window.close() doesn't work (some browsers block it), show message
                setTimeout(() => {
                    document.querySelector('.countdown').innerHTML =
                        'If this window doesn\'t close automatically, you may close it manually.';
                }, 500);
            }
        }
        window.onload = updateCountdown;
    </script>
</head>
<body>
    <div class="container">
        <div class="icon">✅</div>
        <h1>Authentication Successful!</h1>
        <p>You will be redirected in a few moments.</p>
        <div class="countdown">
            <span class="spinner"></span>
            Closing in <span id="countdown">3</span> seconds...
        </div>
    </div>
</body>
</html>
)html";
            request.reply(status_codes::OK,
                          utility::conversions::to_string_t(successHtml),
                          U("text/html"));
            callbackReceived = true; });

        listener.open().wait();

        // Wait for callback with timeout
        const int sleepMs = 100;
        int elapsed = 0;
        int maxWait = timeoutSeconds * 1000;

        while (!callbackReceived && elapsed < maxWait)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(sleepMs));
            elapsed += sleepMs;
        }

        listener.close().wait();
        return authCode;
    }

} // namespace auth0_flutter
