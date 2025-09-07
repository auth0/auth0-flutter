#define _CRT_SECURE_NO_WARNINGS
#define _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
#define _SILENCE_STDEXT_ARR_ITERS_DEPRECATION_WARNING
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

using namespace web;
using namespace web::http;
using namespace web::http::client;
using namespace web::http::experimental::listener;

namespace auth0_flutter {
  void DebugPrint(const std::string& msg) {
    OutputDebugStringA((msg + "\n").c_str());
}

// -------------------- PKCE Helpers --------------------

// Base64 URL-safe encode without padding
// Helper: Base64 URL-safe encode (no padding, + → -, / → _)
std::string base64UrlEncode(const std::vector<unsigned char>& data) {
    static const char* b64chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string result;
    size_t i = 0;
    unsigned char a3[3];
    unsigned char a4[4];

    for (size_t pos = 0; pos < data.size();) {
        int len = 0;
        for (i = 0; i < 3; i++) {
            if (pos < data.size()) {
                a3[i] = data[pos++];
                len++;
            } else {
                a3[i] = 0;
            }
        }

        a4[0] = (a3[0] & 0xfc) >> 2;
        a4[1] = ((a3[0] & 0x03) << 4) + ((a3[1] & 0xf0) >> 4);
        a4[2] = ((a3[1] & 0x0f) << 2) + ((a3[2] & 0xc0) >> 6);
        a4[3] = a3[2] & 0x3f;

        for (i = 0; i < 4; i++) {
            if (i <= (size_t)(len + 0)) {
                result += b64chars[a4[i]];
            } else {
                result += '=';
            }
        }
    }

    // Make it URL-safe
    for (auto& c : result) {
        if (c == '+') c = '-';
        if (c == '/') c = '_';
    }

    // Strip padding '='
    while (!result.empty() && result.back() == '=') {
        result.pop_back();
    }

    return result;
}

// Generate random code verifier (32 bytes -> URL-safe string)
std::string generateCodeVerifier() {
    std::vector<unsigned char> buffer(32);
    if (RAND_bytes(buffer.data(), static_cast<int>(buffer.size())) != 1) {
        throw std::runtime_error("Failed to generate random bytes");
    }
    return base64UrlEncode(buffer);
}

// Generate code challenge from verifier (SHA256 + base64URL)
std::string generateCodeChallenge(const std::string& verifier) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(reinterpret_cast<const unsigned char*>(verifier.data()),
           verifier.size(),
           hash);

    std::vector<unsigned char> digest(hash, hash + SHA256_DIGEST_LENGTH);
    return base64UrlEncode(digest);
}


// ---------- Helpers: URL-decode, safe query parse, and waitForAuthCode (custom scheme) ----------

static std::string UrlDecode(const std::string& str) {
    std::string out;
    out.reserve(str.size());
    for (size_t i = 0; i < str.size(); ++i) {
        char c = str[i];
        if (c == '%') {
            if (i + 2 < str.size()) {
                std::string hex = str.substr(i + 1, 2);
                char decoded = (char)strtol(hex.c_str(), nullptr, 16);
                out.push_back(decoded);
                i += 2;
            }
            // else malformed percent-encoding: skip
        } else if (c == '+') {
            out.push_back(' ');
        } else {
            out.push_back(c);
        }
    }
    return out;
}

static std::map<std::string, std::string> SafeParseQuery(const std::string& query) {
    std::map<std::string, std::string> params;
    size_t start = 0;
    while (start < query.size()) {
        size_t eq = query.find('=', start);
        if (eq == std::string::npos) {
            break; // no more key=value pairs
        }
        std::string key = query.substr(start, eq - start);
        size_t amp = query.find('&', eq + 1);
        std::string value;
        if (amp == std::string::npos) {
            value = query.substr(eq + 1);
            start = query.size();
        } else {
            value = query.substr(eq + 1, amp - (eq + 1));
            start = amp + 1;
        }
        params[UrlDecode(key)] = UrlDecode(value);
    }
    return params;
}

// Safe UTF conversions (wchar_t <-> UTF-8)
static std::string WideToUtf8(const std::wstring& wstr) {
  if (wstr.empty()) return {};
  int size_needed = ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(),
                                         (int)wstr.size(), nullptr, 0, nullptr, nullptr);
  if (size_needed <= 0) return {};
  std::string str(size_needed, 0);
  ::WideCharToMultiByte(CP_UTF8, 0, wstr.data(), (int)wstr.size(), &str[0], size_needed, nullptr, nullptr);
  return str;
}

// Poll environment variable PLUGIN_STARTUP_URL for redirect URI (set by runner/main on startup or IPC).
// Example stored value: auth0flutter://callback?code=AUTH_CODE&state=xyz
static std::string waitForAuthCode_CustomScheme(const std::string& expectedRedirectBase, int timeoutSeconds = 180) {
    const int sleepMs = 200;
    int elapsed = 0;
auto readAndClearEnv = []() -> std::string {
  // Ask Windows how many wchar_t characters are needed (including null)
  DWORD bufSize = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", NULL, 0);
  if (bufSize == 0) return std::string();

  std::vector<wchar_t> buf(bufSize);
  DWORD ret = GetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", buf.data(), bufSize);
  if (ret == 0 || ret >= bufSize) {
    return std::string();
  }

  // Clear it so it's not consumed twice
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");

  // Convert wide -> UTF-8 safely
  std::wstring wstr(buf.data(), ret);
  return WideToUtf8(wstr);
};


    while (elapsed < timeoutSeconds * 1000) {
        std::string uri = readAndClearEnv();
        if (!uri.empty()) {
        //    DebugPrint("Received startup URI: " + uri);
            // Optionally: verify prefix matches expectedRedirectBase (e.g. "auth0flutter://callback")
            if (!expectedRedirectBase.empty()) {
                if (uri.rfind(expectedRedirectBase, 0) != 0) {
             //       DebugPrint("Warning: received URI does not start with expected redirect base");
                    // continue — but still try to parse if present
                }
            }
            // find query
            auto qpos = uri.find('?');
            if (qpos == std::string::npos) {
                return std::string(); // no query params
            }
            std::string query = uri.substr(qpos + 1);
            auto params = SafeParseQuery(query);
            auto it = params.find("code");
            if (it != params.end()) {
                return it->second;
            } else {
                // maybe error param present
                if (params.find("error") != params.end()) {
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

std::string waitForAuthCode(const std::string& redirectUri) {
  uri u(utility::conversions::to_string_t(redirectUri));
  http_listener listener(u);

  std::string authCode;

  listener.support(methods::GET, [&](http_request request) {
    auto queries = uri::split_query(request.request_uri().query());
    auto it = queries.find(U("code"));
    if (it != queries.end()) {
      authCode = utility::conversions::to_utf8string(it->second);
    }

    request.reply(status_codes::OK,
                  U("Login successful! You may close this window."));
  });

  listener.open().wait();

  while (authCode.empty()) {
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
  listener.close().wait();
  return authCode;
}

// -------------------- Token Exchange --------------------
web::json::value exchangeCodeForTokens(
    const std::string& domain,
    const std::string& clientId,
    const std::string& redirectUri,
    const std::string& code,
    const std::string& codeVerifier) {
  
  http_client client(U("https://" + utility::conversions::to_string_t(domain)));

  http_request request(methods::POST);
  request.set_request_uri(U("/oauth/token"));
  request.headers().set_content_type(U("application/json"));

  web::json::value body;
  body[U("grant_type")] = web::json::value::string(U("authorization_code"));
  body[U("client_id")] = web::json::value::string(utility::conversions::to_string_t(clientId));
  body[U("code")] = web::json::value::string(utility::conversions::to_string_t(code));
  body[U("redirect_uri")] = web::json::value::string(utility::conversions::to_string_t(redirectUri));
  body[U("code_verifier")] = web::json::value::string(utility::conversions::to_string_t(codeVerifier));
    DebugPrint("codeVerifier = " + codeVerifier);
      DebugPrint("redirect_uri = " + redirectUri);  
  request.set_body(body);

  auto response = client.request(request).get();

  // ---- Debug: status & headers ----
  DebugPrint("HTTP Status: " + std::to_string(response.status_code()));
  for (const auto& h : response.headers()) {
    DebugPrint("Header: " + utility::conversions::to_utf8string(h.first) + 
               " = " + utility::conversions::to_utf8string(h.second));
  }

  // ---- Read response body as string ----
  auto bodyStr = response.extract_string().get();
  DebugPrint("Response Body: " + utility::conversions::to_utf8string(bodyStr));

  if (response.status_code() != status_codes::OK) {
    throw std::runtime_error("Token request failed: " + utility::conversions::to_utf8string(bodyStr));
  }

  // ---- Parse JSON if successful ----
  return web::json::value::parse(bodyStr);
}

// web::json::value exchangeCodeForTokens(
//     const std::string& domain,
//     const std::string& clientId,
//     const std::string& redirectUri,
//     const std::string& code,
//     const std::string& codeVerifier) {
//   DebugPrint("domain=" + domain);
// DebugPrint("clientId=" + clientId);
// DebugPrint("redirectUri=" + redirectUri);
// DebugPrint("code=" + code);
// DebugPrint("codeVerifier=" + codeVerifier);
//   http_client client(
//       U("https://" + utility::conversions::to_string_t(domain)));

//   http_request request(methods::POST);
//   request.set_request_uri(U("/oauth/token"));
//   request.headers().set_content_type(U("application/json"));

//   web::json::value body;
//   body[U("grant_type")] = web::json::value::string(U("authorization_code"));
//   body[U("client_id")] =
//       web::json::value::string(utility::conversions::to_string_t(clientId));
//   body[U("code")] =
//       web::json::value::string(utility::conversions::to_string_t(code));
//   body[U("redirect_uri")] =
//       web::json::value::string(utility::conversions::to_string_t(redirectUri));
//   body[U("code_verifier")] =
//       web::json::value::string(utility::conversions::to_string_t(codeVerifier));

//   request.set_body(body);

//   auto response = client.request(request).get();
//   if (response.status_code() != status_codes::OK) {
//     throw std::runtime_error("Token request failed");
//   }

//   return response.extract_json().get();
// }

// -------------------- Plugin Impl --------------------

void Auth0FlutterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "auth0.com/auth0_flutter/web_auth",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<Auth0FlutterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

Auth0FlutterPlugin::Auth0FlutterPlugin() {}
Auth0FlutterPlugin::~Auth0FlutterPlugin() {}



void Auth0FlutterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("webAuth#login") == 0) {
    // Top-level args should be a map
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("bad_args", "Expected a map as arguments");
      return;
    }

    // Extract "account" map
    auto accountIt = args->find(flutter::EncodableValue("_account"));
    if (accountIt == args->end()) {
      result->Error("bad_args", "Missing 'account' key");
      return;
    }

    const auto* accountMap = std::get_if<flutter::EncodableMap>(&accountIt->second);
    if (!accountMap) {
      result->Error("bad_args", "'account' is not a map");
      return;
    }

    // Extract clientId and domain
    std::string clientId;
    std::string domain;

    if (auto it = accountMap->find(flutter::EncodableValue("clientId"));
        it != accountMap->end()) {
      clientId = std::get<std::string>(it->second);
    }

    if (auto it = accountMap->find(flutter::EncodableValue("domain"));
        it != accountMap->end()) {
      domain = std::get<std::string>(it->second);
    }
    
    std::string redirectUri = "auth0flutter://callback";


    try {
      // 1. PKCE
      std::string codeVerifier = generateCodeVerifier();
      std::string codeChallenge = generateCodeChallenge(codeVerifier);
      DebugPrint("codeVerifier = " + codeVerifier);
      DebugPrint("codeChallenge = " + codeChallenge);  
      // 2. Build Auth URL
      std::ostringstream authUrl;
      authUrl << "https://" << domain << "/authorize?"
              << "response_type=code"
              << "&client_id=" << clientId
              << "&redirect_uri=" << redirectUri
              << "&scope=openid%20profile%20email"
              << "&code_challenge=" << codeChallenge
              << "&code_challenge_method=S256";
      DebugPrint("authUrl = " + authUrl.str());

      // 3. Open browser
      ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

      // 4. Wait for callback
      std::string code = waitForAuthCode_CustomScheme(redirectUri, 180);

      // 5. Exchange code for tokens
      auto tokens =
          exchangeCodeForTokens(domain, clientId, redirectUri, code, codeVerifier);

      result->Success(flutter::EncodableValue(
          utility::conversions::to_utf8string(tokens.serialize())));
    } catch (const std::exception& e) {
      result->Error("auth_failed", e.what());
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace auth0_flutter
