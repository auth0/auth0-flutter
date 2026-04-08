#pragma once

#include <string>
#include "credentials.h"

class Auth0Client
{
public:
  Auth0Client(std::string domain, std::string clientId, std::string auth0ClientHeader);

  Credentials ExchangeCodeForTokens(
      const std::string &redirectUri,
      const std::string &code,
      const std::string &codeVerifier);

private:
  std::string domain_;
  std::string clientId_;
  std::string auth0ClientHeader_;
};

/// Builds the base64url-encoded Auth0-Client telemetry header value.
/// @param name    SDK name, e.g. "auth0-flutter"
/// @param version SDK version, e.g. "2.1.0-beta.1"
std::string BuildAuth0ClientHeader(const std::string &name, const std::string &version);
