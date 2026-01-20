#include <gtest/gtest.h>

#include "token_decoder.h"
#include <cpprest/json.h>
#include <chrono>

using web::json::value;

/* ---------------- DecodeTokenResponse ---------------- */

TEST(DecodeTokenResponseTest, DecodesMinimalResponse) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_EQ(creds.accessToken, "test_access_token");
  EXPECT_EQ(creds.tokenType, "Bearer");
  EXPECT_FALSE(creds.idToken.empty());  // Empty, not uninitialized
  EXPECT_FALSE(creds.refreshToken.has_value());
  EXPECT_FALSE(creds.expiresIn.has_value());
  EXPECT_FALSE(creds.expiresAt.has_value());
  EXPECT_TRUE(creds.scope.empty());
}

TEST(DecodeTokenResponseTest, DecodesFullResponse) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("id_token")] = value::string(U("test_id_token"));
  json[U("refresh_token")] = value::string(U("test_refresh_token"));
  json[U("expires_in")] = value::number(3600);
  json[U("scope")] = value::string(U("openid profile email"));

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_EQ(creds.accessToken, "test_access_token");
  EXPECT_EQ(creds.tokenType, "Bearer");
  EXPECT_EQ(creds.idToken, "test_id_token");
  ASSERT_TRUE(creds.refreshToken.has_value());
  EXPECT_EQ(creds.refreshToken.value(), "test_refresh_token");
  ASSERT_TRUE(creds.expiresIn.has_value());
  EXPECT_EQ(creds.expiresIn.value(), 3600);
  ASSERT_TRUE(creds.expiresAt.has_value());  // Should be computed from expires_in

  ASSERT_EQ(creds.scope.size(), 3u);
  EXPECT_EQ(creds.scope[0], "openid");
  EXPECT_EQ(creds.scope[1], "profile");
  EXPECT_EQ(creds.scope[2], "email");
}

TEST(DecodeTokenResponseTest, ComputesExpiresAtFromExpiresIn) {
  auto before = std::chrono::system_clock::now();

  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("expires_in")] = value::number(7200);  // 2 hours

  Credentials creds = DecodeTokenResponse(json);

  auto after = std::chrono::system_clock::now();

  ASSERT_TRUE(creds.expiresIn.has_value());
  EXPECT_EQ(creds.expiresIn.value(), 7200);
  ASSERT_TRUE(creds.expiresAt.has_value());

  // Verify expiresAt is approximately now + 7200 seconds
  auto expected = before + std::chrono::seconds(7200);
  auto diff = std::chrono::duration_cast<std::chrono::seconds>(
      creds.expiresAt.value() - expected).count();

  // Allow a small margin for test execution time
  EXPECT_LE(std::abs(diff), 2);
}

TEST(DecodeTokenResponseTest, UsesExplicitExpiresAt) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("expires_at")] = value::string(U("2025-12-31T23:59:59Z"));

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_TRUE(creds.expiresAt.has_value());

  // Convert back to verify
  std::time_t t = std::chrono::system_clock::to_time_t(creds.expiresAt.value());
  std::tm tm{};

  #if defined(_WIN32)
    gmtime_s(&tm, &t);
  #else
    gmtime_r(&t, &tm);
  #endif

  EXPECT_EQ(tm.tm_year + 1900, 2025);
  EXPECT_EQ(tm.tm_mon + 1, 12);
  EXPECT_EQ(tm.tm_mday, 31);
}

TEST(DecodeTokenResponseTest, PrefersExpiresAtOverExpiresIn) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("expires_at")] = value::string(U("2025-12-31T23:59:59Z"));
  json[U("expires_in")] = value::number(3600);  // This should be ignored

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_TRUE(creds.expiresAt.has_value());

  // Verify it's the explicit date, not now + 3600
  std::time_t t = std::chrono::system_clock::to_time_t(creds.expiresAt.value());
  std::tm tm{};

  #if defined(_WIN32)
    gmtime_s(&tm, &t);
  #else
    gmtime_r(&t, &tm);
  #endif

  EXPECT_EQ(tm.tm_year + 1900, 2025);
}

TEST(DecodeTokenResponseTest, HandlesSingleScope) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("scope")] = value::string(U("openid"));

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_EQ(creds.scope.size(), 1u);
  EXPECT_EQ(creds.scope[0], "openid");
}

TEST(DecodeTokenResponseTest, HandlesEmptyScope) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("scope")] = value::string(U(""));

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_TRUE(creds.scope.empty());
}

TEST(DecodeTokenResponseTest, HandlesScopeWithMultipleSpaces) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("scope")] = value::string(U("openid  profile   email"));

  Credentials creds = DecodeTokenResponse(json);

  // Multiple spaces should be handled by istringstream
  ASSERT_EQ(creds.scope.size(), 3u);
  EXPECT_EQ(creds.scope[0], "openid");
  EXPECT_EQ(creds.scope[1], "profile");
  EXPECT_EQ(creds.scope[2], "email");
}

TEST(DecodeTokenResponseTest, ThrowsOnMissingAccessToken) {
  value json;
  json[U("token_type")] = value::string(U("Bearer"));

  EXPECT_THROW(DecodeTokenResponse(json), web::json::json_exception);
}

TEST(DecodeTokenResponseTest, ThrowsOnMissingTokenType) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));

  EXPECT_THROW(DecodeTokenResponse(json), web::json::json_exception);
}

TEST(DecodeTokenResponseTest, HandlesNonIntegerExpiresIn) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("expires_in")] = value::string(U("not_a_number"));

  // Should not throw, just skip expires_in
  Credentials creds = DecodeTokenResponse(json);

  EXPECT_FALSE(creds.expiresIn.has_value());
  EXPECT_FALSE(creds.expiresAt.has_value());
}

TEST(DecodeTokenResponseTest, HandlesInvalidExpiresAtFormat) {
  value json;
  json[U("access_token")] = value::string(U("test_access_token"));
  json[U("token_type")] = value::string(U("Bearer"));
  json[U("expires_at")] = value::string(U("invalid-date"));
  json[U("expires_in")] = value::number(3600);

  Credentials creds = DecodeTokenResponse(json);

  // Should fall back to computing from expires_in
  ASSERT_TRUE(creds.expiresAt.has_value());
}
