#include "auth0_client.h"

#include <cpprest/http_client.h>
#include <cpprest/json.h>

#include "token_decoder.h"
#include "authentication_error.h"

using namespace web;
using namespace web::http;
using namespace web::http::client;
using namespace auth0_flutter;

Auth0Client::Auth0Client(std::string domain, std::string clientId)
    : domain_(std::move(domain)),
      clientId_(std::move(clientId)) {}

Credentials Auth0Client::ExchangeCodeForTokens(
    const std::string &redirectUri,
    const std::string &code,
    const std::string &codeVerifier)
{

  http_client client(
      U("https://" + utility::conversions::to_string_t(domain_)));

  http_request request(methods::POST);
  request.set_request_uri(U("/oauth/token"));
  request.headers().set_content_type(U("application/json"));

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

    // Any non-2xx response (4xx or 5xx) is treated identically:
    // parse the error body and throw with the real HTTP status code.
    // Mirrors iOS behaviour: guard (200...300).contains(response.statusCode)
    if (response.status_code() < 200 || response.status_code() >= 300)
    {
      throw AuthenticationError(json, response.status_code());
    }

    return DecodeTokenResponse(json);
  }
  catch (const AuthenticationError &)
  {
    throw; // already typed correctly — propagate as-is
  }
  catch (const std::exception &e)
  {
    // Transport-level failure: no connection, DNS error, timeout, TLS error, etc.
    // No HTTP response was received, so statusCode defaults to 0.
    // Mirrors iOS behaviour: E(cause: error!, statusCode: response?.statusCode ?? 0)
    // This ensures IsNetworkError() returns true on the Dart side.
    throw AuthenticationError("network_error", e.what(), 0);
  }
}