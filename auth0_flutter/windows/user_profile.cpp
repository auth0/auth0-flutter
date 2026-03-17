#include "user_profile.h"
#include "time_util.h"
#include <chrono>
#include <ctime>
#include <unordered_set>

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::EncodableList;

// Claims excluded from custom_claims 
static const std::unordered_set<std::string> kNonCustomClaims = {
  // JWT protocol claims
  "aud", "iss", "iat", "exp", "nbf", "nonce", "azp", "auth_time",
  "s_hash", "at_hash", "c_hash",
  // Standard OIDC profile claims
  "sub", "name", "given_name", "family_name", "middle_name", "nickname",
  "preferred_username", "profile", "picture", "website", "email",
  "email_verified", "gender", "birthdate", "zoneinfo", "locale",
  "phone_number", "phone_number_verified", "address", "updated_at"
};

// Structural fields parsed into dedicated UserProfile members
static const std::unordered_set<std::string> kStructuralFields = {
  "user_id", "identities", "user_metadata", "app_metadata"
};

static std::optional<std::string> GetString(
    const EncodableMap& map,
    const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return std::nullopt;
  if (!std::holds_alternative<std::string>(it->second)) return std::nullopt;
  return std::get<std::string>(it->second);
}

static std::optional<bool> GetBool(
    const EncodableMap& map,
    const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return std::nullopt;
  if (!std::holds_alternative<bool>(it->second)) return std::nullopt;
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
  profile.isEmailVerified = GetBool(payload, "email_verified");

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

  // Store only raw OIDC claims in extraInfo — strip structural fields that are
  // already parsed into dedicated members (user_id, identities, etc.).
  for (const auto& kv : payload) {
    if (std::holds_alternative<std::string>(kv.first)) {
      const auto& key = std::get<std::string>(kv.first);
      if (kStructuralFields.find(key) == kStructuralFields.end()) {
        profile.extraInfo[kv.first] = kv.second;
      }
    } else {
      profile.extraInfo[kv.first] = kv.second;
    }
  }
  return profile;
}

flutter::EncodableMap UserProfile::ToMap() const {
  EncodableMap map;

  auto get = [&](const char* key) -> EncodableValue {
    auto it = extraInfo.find(EncodableValue(key));
    return it != extraInfo.end() ? it->second : EncodableValue();
  };

  // All 20 standard OIDC claims — keys and order match UserProfile.toMap()
  // in the Android plugin so that Dart's UserProfile.fromMap() can read them.
  map[EncodableValue("sub")]                   = get("sub");
  map[EncodableValue("name")]                  = get("name");
  map[EncodableValue("given_name")]            = get("given_name");
  map[EncodableValue("family_name")]           = get("family_name");
  map[EncodableValue("middle_name")]           = get("middle_name");
  map[EncodableValue("nickname")]              = get("nickname");
  map[EncodableValue("preferred_username")]    = get("preferred_username");
  map[EncodableValue("profile")]               = get("profile");
  map[EncodableValue("picture")]               = get("picture");
  map[EncodableValue("website")]               = get("website");
  map[EncodableValue("email")]                 = get("email");
  map[EncodableValue("email_verified")]        = get("email_verified");
  map[EncodableValue("gender")]                = get("gender");
  map[EncodableValue("birthdate")]             = get("birthdate");
  map[EncodableValue("zoneinfo")]              = get("zoneinfo");
  map[EncodableValue("locale")]                = get("locale");
  map[EncodableValue("phone_number")]          = get("phone_number");
  map[EncodableValue("phone_number_verified")] = get("phone_number_verified");
  map[EncodableValue("address")]               = get("address");

  // updated_at: the OIDC spec defines it as a Unix timestamp (JSON number),
  // but Dart's UserProfile.fromMap() calls DateTime.parse() on it, so it
  // expects an ISO 8601 string.  Convert the double here; pass null if absent.
  {
    auto it = extraInfo.find(EncodableValue("updated_at"));
    if (it != extraInfo.end() && std::holds_alternative<double>(it->second)) {
      auto tp = std::chrono::system_clock::from_time_t(
          static_cast<std::time_t>(std::get<double>(it->second)));
      map[EncodableValue("updated_at")] = EncodableValue(ToIso8601(tp));
    } else {
      // String value (non-standard) or absent — pass through as-is / null
      map[EncodableValue("updated_at")] =
          (it != extraInfo.end()) ? it->second : EncodableValue();
    }
  }

  EncodableMap customClaims;
  for (const auto& kv : extraInfo) {
    if (std::holds_alternative<std::string>(kv.first)) {
      const auto& key = std::get<std::string>(kv.first);
      if (kNonCustomClaims.find(key) == kNonCustomClaims.end()) {
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