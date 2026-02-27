#include <gtest/gtest.h>

#include "user_profile.h"
#include <flutter/encodable_value.h>

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::EncodableList;

/* ---------------- DeserializeUserProfile ---------------- */

TEST(DeserializeUserProfileTest, ParsesMinimalProfile) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  ASSERT_TRUE(profile.id.has_value());
  EXPECT_EQ(profile.id.value(), "auth0|123456");
  EXPECT_FALSE(profile.name.has_value());
  EXPECT_FALSE(profile.nickname.has_value());
  EXPECT_FALSE(profile.email.has_value());
  EXPECT_TRUE(profile.identities.empty());
}

TEST(DeserializeUserProfileTest, ParsesFullProfile) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  payload[EncodableValue("name")] = EncodableValue("John Doe");
  payload[EncodableValue("nickname")] = EncodableValue("johnd");
  payload[EncodableValue("picture")] = EncodableValue("https://example.com/pic.jpg");
  payload[EncodableValue("email")] = EncodableValue("john@example.com");
  payload[EncodableValue("email_verified")] = EncodableValue(true);
  payload[EncodableValue("given_name")] = EncodableValue("John");
  payload[EncodableValue("family_name")] = EncodableValue("Doe");

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  ASSERT_TRUE(profile.id.has_value());
  EXPECT_EQ(profile.id.value(), "auth0|123456");
  ASSERT_TRUE(profile.name.has_value());
  EXPECT_EQ(profile.name.value(), "John Doe");
  ASSERT_TRUE(profile.nickname.has_value());
  EXPECT_EQ(profile.nickname.value(), "johnd");
  ASSERT_TRUE(profile.pictureURL.has_value());
  EXPECT_EQ(profile.pictureURL.value(), "https://example.com/pic.jpg");
  ASSERT_TRUE(profile.email.has_value());
  EXPECT_EQ(profile.email.value(), "john@example.com");
  ASSERT_TRUE(profile.isEmailVerified.has_value());
  EXPECT_EQ(profile.isEmailVerified.value(), true);
  ASSERT_TRUE(profile.givenName.has_value());
  EXPECT_EQ(profile.givenName.value(), "John");
  ASSERT_TRUE(profile.familyName.has_value());
  EXPECT_EQ(profile.familyName.value(), "Doe");
}

TEST(DeserializeUserProfileTest, HandlesEmailVerifiedFalse) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  payload[EncodableValue("email")] = EncodableValue("john@example.com");
  payload[EncodableValue("email_verified")] = EncodableValue(false);

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_FALSE(profile.isEmailVerified.value());
}

TEST(DeserializeUserProfileTest, HandlesIdentities) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");

  EncodableList identities;
  EncodableMap identity1;
  identity1[EncodableValue("provider")] = EncodableValue("auth0");
  identity1[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  identities.push_back(EncodableValue(identity1));

  EncodableMap identity2;
  identity2[EncodableValue("provider")] = EncodableValue("google-oauth2");
  identity2[EncodableValue("user_id")] = EncodableValue("google-oauth2|789");
  identities.push_back(EncodableValue(identity2));

  payload[EncodableValue("identities")] = EncodableValue(identities);

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_EQ(profile.identities.size(), 2u);
  EXPECT_EQ(profile.identities[0].provider, "auth0");
  EXPECT_EQ(profile.identities[1].provider, "google-oauth2");
}

TEST(DeserializeUserProfileTest, HandlesEmptyIdentities) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  payload[EncodableValue("identities")] = EncodableValue(EncodableList());

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_TRUE(profile.identities.empty());
}

TEST(DeserializeUserProfileTest, HandlesUserMetadata) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");

  EncodableMap userMetadata;
  userMetadata[EncodableValue("favorite_color")] = EncodableValue("blue");
  userMetadata[EncodableValue("hobby")] = EncodableValue("reading");
  payload[EncodableValue("user_metadata")] = EncodableValue(userMetadata);

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_EQ(profile.userMetadata.size(), 2u);
  EXPECT_EQ(std::get<std::string>(profile.userMetadata.at(EncodableValue("favorite_color"))),
            "blue");
  EXPECT_EQ(std::get<std::string>(profile.userMetadata.at(EncodableValue("hobby"))),
            "reading");
}

TEST(DeserializeUserProfileTest, HandlesAppMetadata) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");

  EncodableMap appMetadata;
  appMetadata[EncodableValue("roles")] = EncodableValue("admin");
  appMetadata[EncodableValue("plan")] = EncodableValue("premium");
  payload[EncodableValue("app_metadata")] = EncodableValue(appMetadata);

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_EQ(profile.appMetadata.size(), 2u);
  EXPECT_EQ(std::get<std::string>(profile.appMetadata.at(EncodableValue("roles"))),
            "admin");
  EXPECT_EQ(std::get<std::string>(profile.appMetadata.at(EncodableValue("plan"))),
            "premium");
}

TEST(DeserializeUserProfileTest, PreservesExtraInfo) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  payload[EncodableValue("custom_field")] = EncodableValue("custom_value");

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_EQ(profile.extraInfo.size(), 2u);
  EXPECT_TRUE(profile.extraInfo.find(EncodableValue("user_id")) != profile.extraInfo.end());
  EXPECT_TRUE(profile.extraInfo.find(EncodableValue("custom_field")) != profile.extraInfo.end());
}

TEST(DeserializeUserProfileTest, HandlesNonStringValues) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue(12345);  // Not a string

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  EXPECT_FALSE(profile.id.has_value());
}

TEST(DeserializeUserProfileTest, HandlesNonBoolEmailVerified) {
  EncodableMap payload;
  payload[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  payload[EncodableValue("email_verified")] = EncodableValue("true");  // String, not bool

  UserProfile profile = UserProfile::DeserializeUserProfile(payload);

  // Should default to false
  EXPECT_FALSE(profile.isEmailVerified.value());
}

/* ---------------- ToMap ---------------- */

TEST(UserProfileToMapTest, EncodesBasicFields) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|123456");
  profile.extraInfo[EncodableValue("name")] = EncodableValue("John Doe");
  profile.extraInfo[EncodableValue("email")] = EncodableValue("john@example.com");
  profile.extraInfo[EncodableValue("email_verified")] = EncodableValue(true);

  EncodableMap map = profile.ToMap();

  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("sub"))), "auth0|123456");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("name"))), "John Doe");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("email"))), "john@example.com");
  EXPECT_EQ(std::get<bool>(map.at(EncodableValue("email_verified"))), true);
}

TEST(UserProfileToMapTest, ExtractsCustomClaims) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|123456");
  profile.extraInfo[EncodableValue("https://example.com/roles")] = EncodableValue("admin");
  profile.extraInfo[EncodableValue("https://example.com/plan")] = EncodableValue("premium");
  profile.extraInfo[EncodableValue("regular_field")] = EncodableValue("value");

  EncodableMap map = profile.ToMap();

  auto customClaimsIt = map.find(EncodableValue("custom_claims"));
  ASSERT_TRUE(customClaimsIt != map.end());
  ASSERT_TRUE(std::holds_alternative<EncodableMap>(customClaimsIt->second));

  const auto& customClaims = std::get<EncodableMap>(customClaimsIt->second);
  EXPECT_EQ(customClaims.size(), 2u);
  EXPECT_TRUE(customClaims.find(EncodableValue("https://example.com/roles")) != customClaims.end());
  EXPECT_TRUE(customClaims.find(EncodableValue("https://example.com/plan")) != customClaims.end());
  EXPECT_TRUE(customClaims.find(EncodableValue("regular_field")) == customClaims.end());
}

TEST(UserProfileToMapTest, HandlesEmptyCustomClaims) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|123456");

  EncodableMap map = profile.ToMap();

  auto customClaimsIt = map.find(EncodableValue("custom_claims"));
  ASSERT_TRUE(customClaimsIt != map.end());
  ASSERT_TRUE(std::holds_alternative<EncodableMap>(customClaimsIt->second));

  const auto& customClaims = std::get<EncodableMap>(customClaimsIt->second);
  EXPECT_TRUE(customClaims.empty());
}

TEST(UserProfileToMapTest, HandlesMissingFields) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|123456");

  EncodableMap map = profile.ToMap();

  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("sub"))), "auth0|123456");

  // Other fields should exist but be empty/null
  EXPECT_TRUE(map.find(EncodableValue("name")) != map.end());
  EXPECT_TRUE(map.find(EncodableValue("email")) != map.end());
}

/* ---------------- GetId ---------------- */

TEST(UserProfileGetIdTest, ReturnsIdWhenSet) {
  UserProfile profile;
  profile.id = "auth0|123456";

  auto result = profile.GetId();

  ASSERT_TRUE(result.has_value());
  EXPECT_EQ(result.value(), "auth0|123456");
}

TEST(UserProfileGetIdTest, FallsBackToSubInExtraInfo) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|789");

  auto result = profile.GetId();

  ASSERT_TRUE(result.has_value());
  EXPECT_EQ(result.value(), "auth0|789");
}

TEST(UserProfileGetIdTest, PrefersIdOverSub) {
  UserProfile profile;
  profile.id = "auth0|123456";
  profile.extraInfo[EncodableValue("sub")] = EncodableValue("auth0|789");

  auto result = profile.GetId();

  ASSERT_TRUE(result.has_value());
  EXPECT_EQ(result.value(), "auth0|123456");
}

TEST(UserProfileGetIdTest, ReturnsNulloptWhenNeitherSet) {
  UserProfile profile;

  auto result = profile.GetId();

  EXPECT_FALSE(result.has_value());
}

TEST(UserProfileGetIdTest, ReturnsNulloptWhenSubIsNotString) {
  UserProfile profile;
  profile.extraInfo[EncodableValue("sub")] = EncodableValue(12345);

  auto result = profile.GetId();

  EXPECT_FALSE(result.has_value());
}

/* ---------------- Round-trip tests ---------------- */

TEST(UserProfileRoundTripTest, DeserializeAndToMapPreservesBasicData) {
  EncodableMap original;
  original[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  original[EncodableValue("name")] = EncodableValue("John Doe");
  original[EncodableValue("email")] = EncodableValue("john@example.com");

  UserProfile profile = UserProfile::DeserializeUserProfile(original);
  EncodableMap result = profile.ToMap();

  // Note: user_id becomes sub in ToMap
  EXPECT_TRUE(result.find(EncodableValue("name")) != result.end());
  EXPECT_TRUE(result.find(EncodableValue("email")) != result.end());
}

TEST(UserProfileRoundTripTest, PreservesCustomClaims) {
  EncodableMap original;
  original[EncodableValue("user_id")] = EncodableValue("auth0|123456");
  original[EncodableValue("https://example.com/roles")] = EncodableValue("admin");

  UserProfile profile = UserProfile::DeserializeUserProfile(original);
  EncodableMap result = profile.ToMap();

  auto customClaimsIt = result.find(EncodableValue("custom_claims"));
  ASSERT_TRUE(customClaimsIt != result.end());

  const auto& customClaims = std::get<EncodableMap>(customClaimsIt->second);
  EXPECT_TRUE(customClaims.find(EncodableValue("https://example.com/roles")) != customClaims.end());
}
