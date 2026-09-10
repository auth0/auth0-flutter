#include "user_identity.h"
#include "jwt_util.h"

static std::string GetRequiredString(
    const nlohmann::json& v, const std::string& key) {
  return v.at(key).get<std::string>();
}

static std::optional<std::string> GetOptionalString(
    const nlohmann::json& v, const std::string& key) {
  if (v.contains(key) && v.at(key).is_string()) {
    return v.at(key).get<std::string>();
  }
  return std::nullopt;
}

UserIdentity UserIdentity::FromJson(const nlohmann::json& json) {
  UserIdentity identity;

  identity.id = GetRequiredString(json, "user_id");
  identity.connection = GetRequiredString(json, "connection");
  identity.provider = GetRequiredString(json, "provider");

  if (json.contains("isSocial")) {
    identity.isSocial = json.at("isSocial").get<bool>();
  }

  identity.accessToken = GetOptionalString(json, "access_token");
  identity.accessTokenSecret = GetOptionalString(json, "access_token_secret");

  if (json.contains("profileData") &&
      json.at("profileData").is_object()) {
    for (const auto& kv : json.at("profileData").items()) {
      identity.profileInfo[flutter::EncodableValue(kv.key())] =
          JsonToEncodable(kv.value());
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