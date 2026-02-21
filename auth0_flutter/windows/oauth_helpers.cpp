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

// cpprestsdk for HTTP listener and client
#include <cpprest/http_listener.h>
#include <cpprest/http_client.h>
#include <cpprest/uri.h>

using namespace web;
using namespace web::http;
using namespace web::http::client;
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

    OAuthCallbackResult waitForAuthCode_CustomScheme(
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
                // Only accept callbacks on the fixed redirect URI
                if (uri.rfind(kDefaultRedirectUri, 0) != 0)
                {
                    // Not our callback — keep waiting
                    std::this_thread::sleep_for(std::chrono::milliseconds(sleepMs));
                    elapsed += sleepMs;
                    continue;
                }
                // find query
                auto qpos = uri.find('?');
                if (qpos == std::string::npos)
                {
                    return {false, "", "invalid_callback", "No query parameters in callback URI", false};
                }
                std::string query = uri.substr(qpos + 1);
                auto params = SafeParseQuery(query);

                // Validate state parameter if expected state is provided (CSRF protection)
                if (!expectedState.empty())
                {
                    auto stateIt = params.find("state");
                    if (stateIt == params.end() || stateIt->second != expectedState)
                    {
                        return {false, "", "state_mismatch", "State parameter validation failed (potential CSRF attack)", false};
                    }
                }

                // Check for OAuth error response (e.g., user denied access)
                auto errorIt = params.find("error");
                if (errorIt != params.end())
                {
                    std::string errorCode = errorIt->second;
                    std::string errorDesc;

                    auto errorDescIt = params.find("error_description");
                    if (errorDescIt != params.end())
                    {
                        errorDesc = errorDescIt->second;
                    }

                    return {false, "", errorCode, errorDesc, false};
                }

                // Extract authorization code
                auto codeIt = params.find("code");
                if (codeIt != params.end())
                {
                    return {true, codeIt->second, "", "", false};
                }
                else
                {
                    return {false, "", "invalid_callback", "No authorization code in callback", false};
                }
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(sleepMs));
            elapsed += sleepMs;
        }

        // Timeout - no callback received (user likely closed browser)
        return {false, "", "timeout", "No callback received within timeout period", true};
    }

} // namespace auth0_flutter