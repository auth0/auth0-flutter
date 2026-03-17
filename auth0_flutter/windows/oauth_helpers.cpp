/**
 * @file oauth_helpers.cpp
 * @brief Implementation of OAuth 2.0 and PKCE helper functions
 */

#include "oauth_helpers.h"
#include "url_utils.h"
#include "windows_utils.h"

#include <windows.h>
#include <cctype>
#include <thread>
#include <chrono>
#include <stdexcept>
#include <vector>
#include <sstream>
#include <iomanip>

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

    std::string urlEncode(const std::string &str)
    {
        std::ostringstream encoded;
        encoded.fill('0');
        encoded << std::hex << std::uppercase;

        for (unsigned char c : str)
        {
            if (std::isalnum(static_cast<unsigned char>(c)) || c == '-' || c == '_' || c == '.' || c == '~')
            {
                encoded << c;
            }
            else
            {
                encoded << '%' << std::setw(2) << static_cast<int>(c);
            }
        }

        return encoded.str();
    }

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
                if (i <= static_cast<size_t>(len))
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
        const std::string &expectedState,
        pplx::cancellation_token ct)
    {
        static constexpr DWORD kStackBufChars = 2048;

        auto readAndClearEnv = []() -> std::string
        {
            wchar_t stackBuf[kStackBufChars];
            DWORD ret = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", stackBuf, kStackBufChars);
            if (ret == 0)
                return std::string(); // variable not set

            if (ret < kStackBufChars)
            {
                SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
                return WideToUtf8(std::wstring(stackBuf, ret));
            }

            std::vector<wchar_t> heapBuf(ret + 1);
            DWORD ret2 = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", heapBuf.data(), ret + 1);
            if (ret2 == 0 || ret2 >= ret + 1)
                return std::string();

            SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
            return WideToUtf8(std::wstring(heapBuf.data(), ret2));
        };
    
        const auto deadline = std::chrono::steady_clock::now() +
                              std::chrono::seconds(timeoutSeconds);
        const auto sleepDuration = std::chrono::milliseconds(200);

        while (std::chrono::steady_clock::now() < deadline)
        {
            if (ct.is_canceled())
            {
                pplx::cancel_current_task();
            }

            std::string uri = readAndClearEnv();
            if (!uri.empty())
            {
                if (uri.rfind(kDefaultRedirectUri, 0) != 0)
                {
                    std::this_thread::sleep_for(sleepDuration);
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

                // Validate state parameter unconditionally.
                auto stateIt = params.find("state");
                if (stateIt == params.end() || stateIt->second != expectedState)
                {
                    return {false, "", "state_mismatch", "State parameter validation failed", false};
                }

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
            std::this_thread::sleep_for(sleepDuration);
        }

        // Timeout - no callback received (user likely closed browser)
        return {false, "", "timeout", "No callback received within timeout period", true};
    }

    bool waitForLogoutCallback(
        const std::string &returnToUri,
        int timeoutSeconds,
        pplx::cancellation_token ct)
    {
        static constexpr DWORD kStackBufChars = 2048;

        auto readAndClearEnv = []() -> std::string
        {
            wchar_t stackBuf[kStackBufChars];
            DWORD ret = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", stackBuf, kStackBufChars);
            if (ret == 0)
                return std::string();

            if (ret < kStackBufChars)
            {
                SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
                return WideToUtf8(std::wstring(stackBuf, ret));
            }

            std::vector<wchar_t> heapBuf(ret + 1);
            DWORD ret2 = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", heapBuf.data(), ret + 1);
            if (ret2 == 0 || ret2 >= ret + 1)
                return std::string();

            SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
            return WideToUtf8(std::wstring(heapBuf.data(), ret2));
        };

        const auto deadline = std::chrono::steady_clock::now() +
                              std::chrono::seconds(timeoutSeconds);
        const auto sleepDuration = std::chrono::milliseconds(200);

        while (std::chrono::steady_clock::now() < deadline)
        {
            if (ct.is_canceled())
            {
                pplx::cancel_current_task();
            }

            std::string uri = readAndClearEnv();
            if (!uri.empty() && uri.rfind(returnToUri, 0) == 0)
            {
                return true;
            }

            std::this_thread::sleep_for(sleepDuration);
        }

        return false;
    }

} // namespace auth0_flutter