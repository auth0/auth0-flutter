#pragma once

#include <optional>
#include <string>
#include <flutter/encodable_value.h>
#include <cpprest/json.h>

class UserIdentity {
 public:
  std::string id;
  std::string connection;
  std::string provider;
  bool isSocial = false;
  std::optional<std::string> accessToken;
  std::optional<std::string> accessTokenSecret;
  flutter::EncodableMap profileInfo;

  static UserIdentity FromJson(const web::json::value& json);
    static UserIdentity FromEncodable(const flutter::EncodableMap& map);

  flutter::EncodableMap ToEncodableMap() const;
};