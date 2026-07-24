#include "token_decoder.h"
#include <chrono>
#include <sstream>
#include "time_util.h"
Credentials DecodeTokenResponse(
    const nlohmann::json &json)
{

  Credentials creds;

  // ---- Required fields ----
  if (!json.contains("access_token") || !json.at("access_token").is_string())
  {
    throw std::runtime_error("Token response missing required 'access_token' field");
  }
  creds.accessToken = json.at("access_token").get<std::string>();

  if (!json.contains("token_type") || !json.at("token_type").is_string())
  {
    throw std::runtime_error("Token response missing required 'token_type' field");
  }
  creds.tokenType = json.at("token_type").get<std::string>();

  // ---- Optional fields ----
  if (json.contains("id_token"))
  {
    creds.idToken = json.at("id_token").get<std::string>();
  }

  if (json.contains("refresh_token"))
  {
    creds.refreshToken = json.at("refresh_token").get<std::string>();
  }

  // Use is_number() rather than a strict integer-only check: a server may
  // legitimately emit "expires_in" as a float (e.g. 86400.0), which nlohmann
  // would not consider is_number_integer() even though it is a whole number.
  if (json.contains("expires_in") &&
      json.at("expires_in").is_number())
  {
    creds.expiresIn = json.at("expires_in").get<int64_t>();
  }

  // Try expires_at from JSON
  if (json.contains("expires_at") &&
      json.at("expires_at").is_string())
  {

    auto iso = json.at("expires_at").get<std::string>();

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
  if (json.contains("scope") &&
      json.at("scope").is_string())
  {

    auto scopeStr = json.at("scope").get<std::string>();

    std::istringstream iss(scopeStr);
    std::string s;
    while (iss >> s)
    {
      creds.scope.push_back(s);
    }
  }

  return creds;
}
