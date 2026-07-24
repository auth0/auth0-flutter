#pragma once

#include <string>
#include <nlohmann/json.hpp>

#include <flutter/encodable_value.h>

struct JwtParts
{
  std::string header;
  std::string payload;
  std::string signature;
};

JwtParts SplitJwt(const std::string &token);
nlohmann::json DecodeJwtHeader(const std::string &token);
nlohmann::json DecodeJwtPayload(const std::string &token);

flutter::EncodableValue JsonToEncodable(const nlohmann::json &v);