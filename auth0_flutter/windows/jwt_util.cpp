#include "jwt_util.h"

#include <algorithm>
#include <sstream>
#include <vector>
#include <windows.h>
#include <wincrypt.h>

#pragma comment(lib, "Crypt32.lib")

static std::string Base64UrlDecode(const std::string &input)
{
  std::string padded = input;
  std::replace(padded.begin(), padded.end(), '-', '+');
  std::replace(padded.begin(), padded.end(), '_', '/');
  while (padded.size() % 4 != 0)
    padded.push_back('=');

  // First call: determine required buffer size
  DWORD out_len = 0;
  if (!CryptStringToBinaryA(
          padded.c_str(),
          static_cast<DWORD>(padded.size()),
          CRYPT_STRING_BASE64,
          nullptr,
          &out_len,
          nullptr,
          nullptr))
  {
    throw std::runtime_error("Base64 decode failed: unable to determine output size");
  }

  // Second call: perform actual decoding
  std::string output(out_len, '\0');
  if (!CryptStringToBinaryA(
          padded.c_str(),
          static_cast<DWORD>(padded.size()),
          CRYPT_STRING_BASE64,
          reinterpret_cast<BYTE *>(&output[0]),
          &out_len,
          nullptr,
          nullptr))
  {
    throw std::runtime_error("Base64 decode failed: decoding error");
  }

  return output;
}

JwtParts SplitJwt(const std::string &token)
{
  std::stringstream ss(token);
  std::string part;
  std::vector<std::string> parts;

  while (std::getline(ss, part, '.'))
  {
    parts.push_back(part);
  }

  if (parts.size() == 2 && !token.empty() && token.back() == '.')
  {
    parts.push_back("");
  }

  if (parts.size() != 3)
  {
    throw std::runtime_error("JWT must have exactly 3 parts");
  }

  return {parts[0], parts[1], parts[2]};
}

web::json::value DecodeJwtPayload(const std::string &token)
{
  auto parts = SplitJwt(token);
  auto decoded = Base64UrlDecode(parts.payload);
  return web::json::value::parse(decoded);
}

flutter::EncodableValue JsonToEncodable(const web::json::value &v)
{
  if (v.is_null())
    return flutter::EncodableValue();

  if (v.is_boolean())
    return flutter::EncodableValue(v.as_bool());
  if (v.is_number())
    return flutter::EncodableValue(v.as_double());
  if (v.is_string())
    return flutter::EncodableValue(utility::conversions::to_utf8string(v.as_string()));

  if (v.is_array())
  {
    flutter::EncodableList list;
    for (const auto &item : v.as_array())
    {
      list.push_back(JsonToEncodable(item));
    }
    return flutter::EncodableValue(list);
  }

  if (v.is_object())
  {
    flutter::EncodableMap map;
    for (const auto &kv : v.as_object())
    {
      map[flutter::EncodableValue(utility::conversions::to_utf8string(kv.first))] =
          JsonToEncodable(kv.second);
    }
    return flutter::EncodableValue(map);
  }

  return flutter::EncodableValue();
}

flutter::EncodableMap ParseJsonToEncodableMap(const std::string &json)
{
  auto parsed = web::json::value::parse(json);
  auto ev = JsonToEncodable(parsed);
  return std::get<flutter::EncodableMap>(ev);
}