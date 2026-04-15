#include "token_decoder.h"
#include <chrono>
#include <sstream>
#include "time_util.h"
Credentials DecodeTokenResponse(
    const web::json::value &json)
{

  Credentials creds;

  // ---- Required fields ----
  if (!json.has_field(U("access_token")) || !json.at(U("access_token")).is_string())
  {
    throw std::runtime_error("Token response missing required 'access_token' field");
  }
  creds.accessToken =
      utility::conversions::to_utf8string(
          json.at(U("access_token")).as_string());

  if (!json.has_field(U("token_type")) || !json.at(U("token_type")).is_string())
  {
    throw std::runtime_error("Token response missing required 'token_type' field");
  }
  creds.tokenType =
      utility::conversions::to_utf8string(
          json.at(U("token_type")).as_string());

  // ---- Optional fields ----
  if (json.has_field(U("id_token")))
  {
    creds.idToken =
        utility::conversions::to_utf8string(
            json.at(U("id_token")).as_string());
  }

  if (json.has_field(U("refresh_token")))
  {
    creds.refreshToken =
        utility::conversions::to_utf8string(
            json.at(U("refresh_token")).as_string());
  }

  if (json.has_field(U("expires_in")) &&
      json.at(U("expires_in")).is_integer())
  {
    creds.expiresIn = json.at(U("expires_in")).as_integer();
  }

  // Try expires_at from JSON
  if (json.has_field(U("expires_at")) &&
      json.at(U("expires_at")).is_string())
  {

    auto iso = utility::conversions::to_utf8string(
        json.at(U("expires_at")).as_string());

    creds.expiresAt = ParseIso8601(iso);
  }

  // If expires_at missing, compute from expires_in
  if (!creds.expiresAt.has_value() && creds.expiresIn.has_value())
  {
    creds.expiresAt =
        std::chrono::system_clock::now() +
        std::chrono::seconds(creds.expiresIn.value());
  }

  // --------------------------------------------------

  // scope (optional, space-separated string)
  if (json.has_field(U("scope")) &&
      json.at(U("scope")).is_string())
  {

    auto scopeStr = utility::conversions::to_utf8string(
        json.at(U("scope")).as_string());

    std::istringstream iss(scopeStr);
    std::string s;
    while (iss >> s)
    {
      creds.scope.push_back(s);
    }
  }

  return creds;
}
