#pragma once

#include <string>
#include <vector>
#include <optional>
#include <chrono>

#include <flutter/encodable_value.h>

#include "user_profile.h"

class Credentials {
 public:
  // ===== Raw credential fields =====
  std::string accessToken;
  std::string idToken;
  std::string tokenType;

  std::optional<std::string> refreshToken;
  std::optional<int64_t> expiresIn; // seconds
  std::optional<std::chrono::system_clock::time_point> expiresAt;

  std::vector<std::string> scope;
};
