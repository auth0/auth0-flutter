#include "token_decoder.h"
#include <chrono>

Credentials DecodeTokenResponse(
    const web::json::value& json) {

  Credentials creds;

  // ---- Required fields ----
  creds.accessToken =
      utility::conversions::to_utf8string(
          json.at(U("access_token")).as_string());

  creds.tokenType =
      utility::conversions::to_utf8string(
          json.at(U("token_type")).as_string());

  // ---- Optional fields ----
  if (json.has_field(U("id_token"))) {
    creds.idToken =
        utility::conversions::to_utf8string(
            json.at(U("id_token")).as_string());
  }

  if (json.has_field(U("refresh_token"))) {
    creds.refreshToken =
        utility::conversions::to_utf8string(
            json.at(U("refresh_token")).as_string());
  }

  // ---- Scopes (space-separated) ----
  if (json.has_field(U("scope"))) {
    auto scopeStr =
        utility::conversions::to_utf8string(
            json.at(U("scope")).as_string());

    size_t pos = 0;
    while ((pos = scopeStr.find(' ')) != std::string::npos) {
      creds.scopes.push_back(scopeStr.substr(0, pos));
      scopeStr.erase(0, pos + 1);
    }
    if (!scopeStr.empty()) {
      creds.scopes.push_back(scopeStr);
    }
  }

  // ---- expires_in → expiresAt (Kotlin-equivalent logic) ----
  if (json.has_field(U("expires_in"))) {
    long long expiresIn =
        json.at(U("expires_in")).as_integer();

    creds.expiresIn = expiresIn;

    auto now = std::chrono::system_clock::now();
    creds.expiresAt =
        now + std::chrono::seconds(expiresIn);
  }

  return creds;
}
