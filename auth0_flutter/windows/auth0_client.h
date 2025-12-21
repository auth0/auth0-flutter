#pragma once

#include <string>
#include "credentials.h"

class Auth0Client {
public:
  Auth0Client(std::string domain, std::string clientId);

  Credentials ExchangeCodeForTokens(
      const std::string& redirectUri,
      const std::string& code,
      const std::string& codeVerifier);

private:
  std::string domain_;
  std::string clientId_;
};
