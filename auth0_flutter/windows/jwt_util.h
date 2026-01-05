#pragma once

#include <string>
#include <cpprest/json.h>
#include <flutter/encodable_value.h>

struct JwtParts
{
  std::string header;
  std::string payload;
  std::string signature;
};

JwtParts SplitJwt(const std::string &token);
web::json::value DecodeJwtPayload(const std::string &token);

// SAFE conversion
flutter::EncodableMap ParseJsonToEncodableMap(const std::string &json);
flutter::EncodableValue JsonToEncodable(const web::json::value &v);