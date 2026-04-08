#include "auth0_client.h"

#include <cpprest/http_client.h>
#include <cpprest/json.h>
#include <windows.h>
#include <versionhelpers.h>

#include <sstream>
#include <iomanip>

#include "token_decoder.h"
#include "authentication_error.h"

using namespace web;
using namespace web::http;
using namespace web::http::client;
using namespace auth0_flutter;

// ---------------------------------------------------------------------------
// Telemetry helpers
// ---------------------------------------------------------------------------

static std::string Base64UrlEncode(const std::string &input)
{
    static const char kChars[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string result;
    result.reserve(((input.size() + 2) / 3) * 4);
    for (size_t i = 0; i < input.size(); i += 3)
    {
        unsigned int b = static_cast<unsigned char>(input[i]) << 16;
        if (i + 1 < input.size()) b |= static_cast<unsigned char>(input[i + 1]) << 8;
        if (i + 2 < input.size()) b |= static_cast<unsigned char>(input[i + 2]);
        result += kChars[(b >> 18) & 0x3F];
        result += kChars[(b >> 12) & 0x3F];
        if (i + 1 < input.size()) result += kChars[(b >>  6) & 0x3F];
        if (i + 2 < input.size()) result += kChars[(b      ) & 0x3F];
    }
    for (auto &c : result)
    {
        if (c == '+') c = '-';
        else if (c == '/') c = '_';
    }
    // Remove base64 padding – Auth0 expects unpadded base64url
    while (!result.empty() && result.back() == '=') result.pop_back();
    return result;
}

static std::string GetWindowsVersion()
{
    // RtlGetVersion is the only reliable API on Windows 10+ (GetVersionEx lies).
    OSVERSIONINFOEXW osvi = {};
    osvi.dwOSVersionInfoSize = sizeof(osvi);

    using RtlGetVersionFn = NTSTATUS(WINAPI *)(OSVERSIONINFOEXW *);
    auto *ntdll = ::GetModuleHandleW(L"ntdll.dll");
    if (ntdll)
    {
        auto fn = reinterpret_cast<RtlGetVersionFn>(
            ::GetProcAddress(ntdll, "RtlGetVersion"));
        if (fn) fn(&osvi);
    }

    std::ostringstream oss;
    oss << osvi.dwMajorVersion << "." << osvi.dwMinorVersion;
    return oss.str();
}

std::string BuildAuth0ClientHeader(const std::string &name, const std::string &version)
{
    // Mirror the Swift Telemetry format:
    // { "name": "auth0-flutter", "version": "x.y.z", "env": { "Windows": "10.0" } }
    std::ostringstream json;
    json << "{"
         << "\"name\":\"" << name << "\","
         << "\"version\":\"" << version << "\","
         << "\"env\":{"
         <<   "\"Windows\":\"" << GetWindowsVersion() << "\""
         << "}"
         << "}";
    return Base64UrlEncode(json.str());
}

// ---------------------------------------------------------------------------
// Auth0Client
// ---------------------------------------------------------------------------

Auth0Client::Auth0Client(std::string domain, std::string clientId, std::string auth0ClientHeader)
    : domain_(std::move(domain)),
      clientId_(std::move(clientId)),
      auth0ClientHeader_(std::move(auth0ClientHeader)) {}

Credentials Auth0Client::ExchangeCodeForTokens(
    const std::string &redirectUri,
    const std::string &code,
    const std::string &codeVerifier)
{
  http_client_config config;
  config.set_timeout(std::chrono::seconds(30));

  http_client client(
      U("https://" + utility::conversions::to_string_t(domain_)), config);

  http_request request(methods::POST);
  request.set_request_uri(U("/oauth/token"));
  request.headers().set_content_type(U("application/json"));

  if (!auth0ClientHeader_.empty())
  {
      request.headers().add(
          U("Auth0-Client"),
          utility::conversions::to_string_t(auth0ClientHeader_));
  }

  web::json::value body;
  body[U("grant_type")] = web::json::value::string(U("authorization_code"));
  body[U("client_id")] = web::json::value::string(utility::conversions::to_string_t(clientId_));
  body[U("code")] = web::json::value::string(utility::conversions::to_string_t(code));
  body[U("redirect_uri")] = web::json::value::string(utility::conversions::to_string_t(redirectUri));
  body[U("code_verifier")] = web::json::value::string(utility::conversions::to_string_t(codeVerifier));

  request.set_body(body);

  try
  {
    auto response = client.request(request).get();
    auto json     = response.extract_json().get();

    if (response.status_code() < 200 || response.status_code() >= 300)
    {
      throw AuthenticationError(json, response.status_code());
    }

    return DecodeTokenResponse(json);
  }
  catch (const AuthenticationError &)
  {
    throw;
  }
  catch (const std::exception &e)
  {
    throw AuthenticationError("network_error", e.what(), 0);
  }
}
