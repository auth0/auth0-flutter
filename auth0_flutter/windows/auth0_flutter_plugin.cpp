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

// -------------------- PKCE Helpers --------------------

// Base64 URL-safe encode without padding
std::string base64UrlEncode(const unsigned char* data, size_t len) {
  static const char* chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

  std::string out;
  int val = 0, valb = -6;
  for (size_t i = 0; i < len; i++) {
    val = (val << 8) + data[i];
    valb += 8;
    while (valb >= 0) {
      out.push_back(chars[(val >> valb) & 0x3F]);
      valb -= 6;
    }
  }
  if (valb > -6) out.push_back(chars[((val << 8) >> (valb + 8)) & 0x3F]);
  return out;
}

std::string generateCodeVerifier() {
  std::array<unsigned char, 32> buffer;
  if (RAND_bytes(buffer.data(), buffer.size()) != 1) {
    throw std::runtime_error("Failed to generate random bytes for PKCE");
  }

  // URL-safe chars
  static const char* chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

  std::string verifier;
  for (auto b : buffer) {
    verifier.push_back(chars[b % 64]);
  }
  return verifier;
}

std::string generateCodeChallenge(const std::string& verifier) {
  unsigned char hash[SHA256_DIGEST_LENGTH];
  SHA256(reinterpret_cast<const unsigned char*>(verifier.data()),
         verifier.size(), hash);
  return base64UrlEncode(hash, SHA256_DIGEST_LENGTH);
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
  
  http_client client(
      U("https://" + utility::conversions::to_string_t(domain)));

  http_request request(methods::POST);
  request.set_request_uri(U("/oauth/token"));
  request.headers().set_content_type(U("application/json"));

  web::json::value body;
  body[U("grant_type")] = web::json::value::string(U("authorization_code"));
  body[U("client_id")] =
      web::json::value::string(utility::conversions::to_string_t(clientId));
  body[U("code")] =
      web::json::value::string(utility::conversions::to_string_t(code));
  body[U("redirect_uri")] =
      web::json::value::string(utility::conversions::to_string_t(redirectUri));
  body[U("code_verifier")] =
      web::json::value::string(utility::conversions::to_string_t(codeVerifier));

  request.set_body(body);

  auto response = client.request(request).get();
  if (response.status_code() != status_codes::OK) {
    throw std::runtime_error("Token request failed");
  }

  return response.extract_json().get();
}

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
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("invalid_args", "Arguments must be a map");
      return;
    }

    std::string clientId =
        std::get<std::string>(args->at(flutter::EncodableValue("clientId")));
    std::string domain =
        std::get<std::string>(args->at(flutter::EncodableValue("domain")));
    std::string redirectUri =
        std::get<std::string>(args->at(flutter::EncodableValue("redirectUri")));

    try {
      // 1. PKCE
      std::string codeVerifier = generateCodeVerifier();
      std::string codeChallenge = generateCodeChallenge(codeVerifier);

      // 2. Build Auth URL
      std::ostringstream authUrl;
      authUrl << "https://" << domain << "/authorize?"
              << "response_type=code"
              << "&client_id=" << clientId
              << "&redirect_uri=" << redirectUri
              << "&scope=openid%20profile%20email"
              << "&code_challenge=" << codeChallenge
              << "&code_challenge_method=S256";

      // 3. Open browser
      ShellExecuteA(NULL, "open", authUrl.str().c_str(), NULL, NULL, SW_SHOWNORMAL);

      // 4. Wait for callback
      std::string code = waitForAuthCode(redirectUri);

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