#include <gtest/gtest.h>

#include "user_identity.h"
#include <cpprest/json.h>
#include <flutter/encodable_value.h>

using web::json::value;
using flutter::EncodableMap;
using flutter::EncodableValue;

/* ---------------- FromJson ---------------- */

TEST(UserIdentityFromJsonTest, ParsesMinimalIdentity) {
  value json;
  json[U("user_id")] = value::string(U("auth0|123456"));
  json[U("connection")] = value::string(U("Username-Password-Authentication"));
  json[U("provider")] = value::string(U("auth0"));

  UserIdentity identity = UserIdentity::FromJson(json);

  EXPECT_EQ(identity.id, "auth0|123456");
  EXPECT_EQ(identity.connection, "Username-Password-Authentication");
  EXPECT_EQ(identity.provider, "auth0");
  EXPECT_FALSE(identity.isSocial);
  EXPECT_FALSE(identity.accessToken.has_value());
  EXPECT_FALSE(identity.accessTokenSecret.has_value());
  EXPECT_TRUE(identity.profileInfo.empty());
}

TEST(UserIdentityFromJsonTest, ParsesFullIdentity) {
  value json;
  json[U("user_id")] = value::string(U("google-oauth2|123456"));
  json[U("connection")] = value::string(U("google-oauth2"));
  json[U("provider")] = value::string(U("google-oauth2"));
  json[U("isSocial")] = value::boolean(true);
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("access_token_secret")] = value::string(U("test_secret"));

  value profileData;
  profileData[U("email")] = value::string(U("user@example.com"));
  profileData[U("name")] = value::string(U("John Doe"));
  json[U("profileData")] = profileData;

  UserIdentity identity = UserIdentity::FromJson(json);

  EXPECT_EQ(identity.id, "google-oauth2|123456");
  EXPECT_EQ(identity.connection, "google-oauth2");
  EXPECT_EQ(identity.provider, "google-oauth2");
  EXPECT_TRUE(identity.isSocial);
  ASSERT_TRUE(identity.accessToken.has_value());
  EXPECT_EQ(identity.accessToken.value(), "test_access_token");
  ASSERT_TRUE(identity.accessTokenSecret.has_value());
  EXPECT_EQ(identity.accessTokenSecret.value(), "test_secret");

  EXPECT_EQ(identity.profileInfo.size(), 2u);
  EXPECT_TRUE(identity.profileInfo.find(EncodableValue("email")) != identity.profileInfo.end());
  EXPECT_TRUE(identity.profileInfo.find(EncodableValue("name")) != identity.profileInfo.end());
}

TEST(UserIdentityFromJsonTest, HandlesSocialIdentityWithoutTokens) {
  value json;
  json[U("user_id")] = value::string(U("facebook|123456"));
  json[U("connection")] = value::string(U("facebook"));
  json[U("provider")] = value::string(U("facebook"));
  json[U("isSocial")] = value::boolean(true);

  UserIdentity identity = UserIdentity::FromJson(json);

  EXPECT_EQ(identity.provider, "facebook");
  EXPECT_TRUE(identity.isSocial);
  EXPECT_FALSE(identity.accessToken.has_value());
  EXPECT_FALSE(identity.accessTokenSecret.has_value());
}

TEST(UserIdentityFromJsonTest, HandlesEmptyProfileData) {
  value json;
  json[U("user_id")] = value::string(U("auth0|123456"));
  json[U("connection")] = value::string(U("Username-Password-Authentication"));
  json[U("provider")] = value::string(U("auth0"));
  json[U("profileData")] = value::object();

  UserIdentity identity = UserIdentity::FromJson(json);

  EXPECT_TRUE(identity.profileInfo.empty());
}

TEST(UserIdentityFromJsonTest, HandlesProfileDataWithVariousTypes) {
  value json;
  json[U("user_id")] = value::string(U("auth0|123456"));
  json[U("connection")] = value::string(U("Username-Password-Authentication"));
  json[U("provider")] = value::string(U("auth0"));

  value profileData;
  profileData[U("string_field")] = value::string(U("text"));
  profileData[U("number_field")] = value::number(42);
  profileData[U("bool_field")] = value::boolean(true);
  json[U("profileData")] = profileData;

  UserIdentity identity = UserIdentity::FromJson(json);

  EXPECT_EQ(identity.profileInfo.size(), 3u);

  auto stringIt = identity.profileInfo.find(EncodableValue("string_field"));
  ASSERT_TRUE(stringIt != identity.profileInfo.end());
  EXPECT_TRUE(std::holds_alternative<std::string>(stringIt->second));

  auto numberIt = identity.profileInfo.find(EncodableValue("number_field"));
  ASSERT_TRUE(numberIt != identity.profileInfo.end());
  EXPECT_TRUE(std::holds_alternative<double>(numberIt->second));

  auto boolIt = identity.profileInfo.find(EncodableValue("bool_field"));
  ASSERT_TRUE(boolIt != identity.profileInfo.end());
  EXPECT_TRUE(std::holds_alternative<bool>(boolIt->second));
}

TEST(UserIdentityFromJsonTest, ThrowsOnMissingRequiredField) {
  value json;
  json[U("user_id")] = value::string(U("auth0|123456"));
  json[U("connection")] = value::string(U("Username-Password-Authentication"));
  // Missing provider

  EXPECT_THROW(UserIdentity::FromJson(json), web::json::json_exception);
}

/* ---------------- FromEncodable ---------------- */

TEST(UserIdentityFromEncodableTest, ParsesProviderAndUserId) {
  EncodableMap map;
  map[EncodableValue("provider")] = EncodableValue("auth0");
  map[EncodableValue("user_id")] = EncodableValue("auth0|123456");

  UserIdentity identity = UserIdentity::FromEncodable(map);

  EXPECT_EQ(identity.provider, "auth0");
  EXPECT_EQ(identity.id, "auth0|123456");
}

TEST(UserIdentityFromEncodableTest, HandlesEmptyMap) {
  EncodableMap map;

  UserIdentity identity = UserIdentity::FromEncodable(map);

  EXPECT_TRUE(identity.provider.empty());
  EXPECT_TRUE(identity.id.empty());
}

TEST(UserIdentityFromEncodableTest, HandlesOnlyProvider) {
  EncodableMap map;
  map[EncodableValue("provider")] = EncodableValue("google-oauth2");

  UserIdentity identity = UserIdentity::FromEncodable(map);

  EXPECT_EQ(identity.provider, "google-oauth2");
  EXPECT_TRUE(identity.id.empty());
}

TEST(UserIdentityFromEncodableTest, HandlesOnlyUserId) {
  EncodableMap map;
  map[EncodableValue("user_id")] = EncodableValue("facebook|789");

  UserIdentity identity = UserIdentity::FromEncodable(map);

  EXPECT_EQ(identity.id, "facebook|789");
  EXPECT_TRUE(identity.provider.empty());
}

TEST(UserIdentityFromEncodableTest, IgnoresNonStringValues) {
  EncodableMap map;
  map[EncodableValue("provider")] = EncodableValue(42);  // Not a string
  map[EncodableValue("user_id")] = EncodableValue(true);  // Not a string

  UserIdentity identity = UserIdentity::FromEncodable(map);

  EXPECT_TRUE(identity.provider.empty());
  EXPECT_TRUE(identity.id.empty());
}

/* ---------------- ToEncodableMap ---------------- */

TEST(UserIdentityToEncodableMapTest, EncodesMinimalIdentity) {
  UserIdentity identity;
  identity.id = "auth0|123456";
  identity.connection = "Username-Password-Authentication";
  identity.provider = "auth0";
  identity.isSocial = false;

  EncodableMap map = identity.ToEncodableMap();

  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("id"))), "auth0|123456");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("connection"))),
            "Username-Password-Authentication");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("provider"))), "auth0");
  EXPECT_EQ(std::get<bool>(map.at(EncodableValue("isSocial"))), false);

  // Optional fields should not be present
  EXPECT_TRUE(map.find(EncodableValue("accessToken")) == map.end());
  EXPECT_TRUE(map.find(EncodableValue("accessTokenSecret")) == map.end());
}

TEST(UserIdentityToEncodableMapTest, EncodesFullIdentity) {
  UserIdentity identity;
  identity.id = "google-oauth2|123456";
  identity.connection = "google-oauth2";
  identity.provider = "google-oauth2";
  identity.isSocial = true;
  identity.accessToken = "test_access_token";
  identity.accessTokenSecret = "test_secret";
  identity.profileInfo[EncodableValue("email")] = EncodableValue("user@example.com");

  EncodableMap map = identity.ToEncodableMap();

  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("id"))), "google-oauth2|123456");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("connection"))), "google-oauth2");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("provider"))), "google-oauth2");
  EXPECT_EQ(std::get<bool>(map.at(EncodableValue("isSocial"))), true);
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("accessToken"))),
            "test_access_token");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("accessTokenSecret"))),
            "test_secret");

  auto profileInfoIt = map.find(EncodableValue("profileInfo"));
  ASSERT_TRUE(profileInfoIt != map.end());
  EXPECT_TRUE(std::holds_alternative<EncodableMap>(profileInfoIt->second));
}

TEST(UserIdentityToEncodableMapTest, HandlesEmptyProfileInfo) {
  UserIdentity identity;
  identity.id = "auth0|123456";
  identity.connection = "Username-Password-Authentication";
  identity.provider = "auth0";

  EncodableMap map = identity.ToEncodableMap();

  // Empty profileInfo should not be included
  EXPECT_TRUE(map.find(EncodableValue("profileInfo")) == map.end());
}

/* ---------------- Round-trip tests ---------------- */

TEST(UserIdentityRoundTripTest, FromJsonToEncodableMapPreservesData) {
  value json;
  json[U("user_id")] = value::string(U("google-oauth2|123456"));
  json[U("connection")] = value::string(U("google-oauth2"));
  json[U("provider")] = value::string(U("google-oauth2"));
  json[U("isSocial")] = value::boolean(true);
  json[U("access_token")] = value::string(U("test_token"));

  UserIdentity identity = UserIdentity::FromJson(json);
  EncodableMap map = identity.ToEncodableMap();

  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("id"))), "google-oauth2|123456");
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("provider"))), "google-oauth2");
  EXPECT_EQ(std::get<bool>(map.at(EncodableValue("isSocial"))), true);
  EXPECT_EQ(std::get<std::string>(map.at(EncodableValue("accessToken"))), "test_token");
}
