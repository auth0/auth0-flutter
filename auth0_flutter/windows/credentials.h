#pragma once
#include <string>
#include <vector>
#include <optional>
#include <chrono>

struct Credentials {
  std::string accessToken;
  std::string idToken;
  std::string refreshToken;
  std::string tokenType;
  std::vector<std::string> scopes;

  std::optional<long long> expiresIn; // seconds
  std::optional<std::chrono::system_clock::time_point> expiresAt;
};
