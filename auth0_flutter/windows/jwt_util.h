#pragma once

#include <string>
#include <cpprest/json.h>

// Conditionally include Flutter types only when building as part of Flutter plugin
#ifndef AUTH0_FLUTTER_STANDALONE_BUILD
#include <flutter/encodable_value.h>
#endif

struct JwtParts
{
  std::string header;
  std::string payload;
  std::string signature;
};

JwtParts SplitJwt(const std::string &token);
web::json::value DecodeJwtHeader(const std::string &token);
web::json::value DecodeJwtPayload(const std::string &token);

// Flutter conversion functions (only available when building with Flutter)
#ifndef AUTH0_FLUTTER_STANDALONE_BUILD
flutter::EncodableMap ParseJsonToEncodableMap(const std::string &json);
flutter::EncodableValue JsonToEncodable(const web::json::value &v);
#endif