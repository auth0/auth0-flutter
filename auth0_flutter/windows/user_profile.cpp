#include "user_profile.h"

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::EncodableList;

static bool IsCustomClaim(const std::string& key) {
  return key.rfind("https://", 0) == 0;
}

static std::optional<std::string> GetString(
    const EncodableMap& map,
    const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return std::nullopt;
  if (!std::holds_alternative<std::string>(it->second)) return std::nullopt;
  return std::get<std::string>(it->second);
}

static bool GetBoolOrFalse(
    const EncodableMap& map,
    const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return false;
  if (!std::holds_alternative<bool>(it->second)) return false;
  return std::get<bool>(it->second);
}

UserProfile UserProfile::DeserializeUserProfile(const EncodableMap& payload) {
  UserProfile profile;

  profile.id = GetString(payload, "user_id");
  profile.name = GetString(payload, "name");
  profile.nickname = GetString(payload, "nickname");
  profile.pictureURL = GetString(payload, "picture");
  profile.email = GetString(payload, "email");
  profile.givenName = GetString(payload, "given_name");
  profile.familyName = GetString(payload, "family_name");
  profile.isEmailVerified = GetBoolOrFalse(payload, "email_verified");

 // identities
auto identities_it = payload.find(flutter::EncodableValue("identities"));
if (identities_it != payload.end() &&
    std::holds_alternative<flutter::EncodableList>(identities_it->second)) {

  const auto& list =
      std::get<flutter::EncodableList>(identities_it->second);

  for (const auto& item : list) {
    if (std::holds_alternative<flutter::EncodableMap>(item)) {
      const auto& map =
          std::get<flutter::EncodableMap>(item);

      profile.identities.emplace_back(
          UserIdentity::FromEncodable(map)
      );
    }
  }
}


  // user_metadata
  auto userMetaIt = payload.find(EncodableValue("user_metadata"));
  if (userMetaIt != payload.end() &&
      std::holds_alternative<EncodableMap>(userMetaIt->second)) {
    profile.userMetadata = std::get<EncodableMap>(userMetaIt->second);
  }

  // app_metadata
  auto appMetaIt = payload.find(EncodableValue("app_metadata"));
  if (appMetaIt != payload.end() &&
      std::holds_alternative<EncodableMap>(appMetaIt->second)) {
    profile.appMetadata = std::get<EncodableMap>(appMetaIt->second);
  }

  profile.extraInfo = payload;
  return profile;
}

flutter::EncodableMap UserProfile::ToMap() const {
  EncodableMap map;

  auto get = [&](const char* key) -> EncodableValue {
    auto it = extraInfo.find(EncodableValue(key));
    return it != extraInfo.end() ? it->second : EncodableValue();
  };

  map[EncodableValue("sub")] = get("sub");
  map[EncodableValue("name")] = get("name");
  map[EncodableValue("given_name")] = get("given_name");
  map[EncodableValue("family_name")] = get("family_name");
  map[EncodableValue("nickname")] = get("nickname");
  map[EncodableValue("picture")] = get("picture");
  map[EncodableValue("email")] = get("email");
  map[EncodableValue("email_verified")] = get("email_verified");

  EncodableMap customClaims;
  for (const auto& kv : extraInfo) {
    if (std::holds_alternative<std::string>(kv.first)) {
      const auto& key = std::get<std::string>(kv.first);
      if (IsCustomClaim(key)) {
        customClaims[kv.first] = kv.second;
      }
    }
  }

  map[EncodableValue("custom_claims")] = customClaims;
  return map;
}

std::optional<std::string> UserProfile::GetId() const {
  if (id) return id;
  auto it = extraInfo.find(EncodableValue("sub"));
  if (it != extraInfo.end() &&
      std::holds_alternative<std::string>(it->second)) {
    return std::get<std::string>(it->second);
  }
  return std::nullopt;
}
