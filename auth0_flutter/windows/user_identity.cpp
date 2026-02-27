#include "user_identity.h"
#include "jwt_util.h"

using web::json::value;

static std::string GetRequiredString(
    const value& v, const utility::string_t& key) {
  return utility::conversions::to_utf8string(v.at(key).as_string());
}

static std::optional<std::string> GetOptionalString(
    const value& v, const utility::string_t& key) {
  if (v.has_field(key) && v.at(key).is_string()) {
    return utility::conversions::to_utf8string(v.at(key).as_string());
  }
  return std::nullopt;
}

UserIdentity UserIdentity::FromJson(const value& json) {
  UserIdentity identity;

  identity.id = GetRequiredString(json, U("user_id"));
  identity.connection = GetRequiredString(json, U("connection"));
  identity.provider = GetRequiredString(json, U("provider"));

  if (json.has_field(U("isSocial"))) {
    identity.isSocial = json.at(U("isSocial")).as_bool();
  }

  identity.accessToken = GetOptionalString(json, U("access_token"));
  identity.accessTokenSecret = GetOptionalString(json, U("access_token_secret"));

  if (json.has_field(U("profileData")) &&
      json.at(U("profileData")).is_object()) {
    for (const auto& kv : json.at(U("profileData")).as_object()) {
      identity.profileInfo[flutter::EncodableValue(
          utility::conversions::to_utf8string(kv.first))] =
          JsonToEncodable(kv.second);
    }
  }

  return identity;
}

UserIdentity UserIdentity::FromEncodable(const flutter::EncodableMap& map) {
  UserIdentity id;

  auto it = map.find(flutter::EncodableValue("provider"));
  if (it != map.end() && std::holds_alternative<std::string>(it->second)) {
    id.provider = std::get<std::string>(it->second);
  }

  it = map.find(flutter::EncodableValue("user_id"));
  if (it != map.end() && std::holds_alternative<std::string>(it->second)) {
    id.id = std::get<std::string>(it->second);
  }

  return id;
}

flutter::EncodableMap UserIdentity::ToEncodableMap() const {
  flutter::EncodableMap map;

  map[flutter::EncodableValue("id")] = flutter::EncodableValue(id);
  map[flutter::EncodableValue("connection")] = flutter::EncodableValue(connection);
  map[flutter::EncodableValue("provider")] = flutter::EncodableValue(provider);
  map[flutter::EncodableValue("isSocial")] = flutter::EncodableValue(isSocial);

  if (accessToken) map[flutter::EncodableValue("accessToken")] = flutter::EncodableValue(*accessToken);
  if (accessTokenSecret) map[flutter::EncodableValue("accessTokenSecret")] = flutter::EncodableValue(*accessTokenSecret);
  if (!profileInfo.empty()) map[flutter::EncodableValue("profileInfo")] = flutter::EncodableValue(profileInfo);

  return map;
}