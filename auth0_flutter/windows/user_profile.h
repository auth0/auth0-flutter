#pragma once

#include <optional>
#include <vector>
#include <string>
#include <flutter/encodable_value.h>
#include "user_identity.h"

class UserProfile {
 public:
  std::optional<std::string> id;
  std::optional<std::string> name;
  std::optional<std::string> nickname;
  std::optional<std::string> pictureURL;
  std::optional<std::string> email;
  std::optional<bool> isEmailVerified;
  std::optional<std::string> familyName;
  std::optional<std::string> givenName;

  std::vector<UserIdentity> identities;
  flutter::EncodableMap userMetadata;
  flutter::EncodableMap appMetadata;
  flutter::EncodableMap extraInfo;

  static UserProfile DeserializeUserProfile(const flutter::EncodableMap& payload);
  flutter::EncodableMap ToMap() const;
  std::optional<std::string> GetId() const;
};