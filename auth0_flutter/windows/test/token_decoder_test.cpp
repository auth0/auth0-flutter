#include <gtest/gtest.h>

#include "token_decoder.h"
#include <nlohmann/json.hpp>
#include <chrono>

/* ---------------- DecodeTokenResponse ---------------- */

TEST(DecodeTokenResponseTest, DecodesMinimalResponse) {
  // openid is always requested, so Auth0 always returns an id_token.
  // The minimal real-world response always includes access_token, token_type, and id_token.
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"]   = "Bearer";
  json["id_token"]     = "test_id_token";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_EQ(creds.accessToken, "test_access_token");
  EXPECT_EQ(creds.tokenType, "Bearer");
  EXPECT_FALSE(creds.idToken.empty());
  EXPECT_EQ(creds.idToken, "test_id_token");
  EXPECT_FALSE(creds.refreshToken.has_value());
  EXPECT_FALSE(creds.expiresIn.has_value());
  EXPECT_FALSE(creds.expiresAt.has_value());
  EXPECT_TRUE(creds.scope.empty());
}

TEST(DecodeTokenResponseTest, DecodesFullResponse) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["id_token"] = "test_id_token";
  json["refresh_token"] = "test_refresh_token";
  json["expires_in"] = 3600;
  json["scope"] = "openid profile email";

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

  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["expires_in"] = 7200;  // 2 hours

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
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["expires_at"] = "2025-12-31T23:59:59Z";

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
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["expires_at"] = "2025-12-31T23:59:59Z";
  json["expires_in"] = 3600;  // This should be ignored

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
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["scope"] = "openid";

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_EQ(creds.scope.size(), 1u);
  EXPECT_EQ(creds.scope[0], "openid");
}

TEST(DecodeTokenResponseTest, HandlesEmptyScope) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["scope"] = "";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_TRUE(creds.scope.empty());
}

TEST(DecodeTokenResponseTest, HandlesScopeWithMultipleSpaces) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["scope"] = "openid  profile   email";

  Credentials creds = DecodeTokenResponse(json);

  // Multiple spaces should be handled by istringstream
  ASSERT_EQ(creds.scope.size(), 3u);
  EXPECT_EQ(creds.scope[0], "openid");
  EXPECT_EQ(creds.scope[1], "profile");
  EXPECT_EQ(creds.scope[2], "email");
}

TEST(DecodeTokenResponseTest, ThrowsOnMissingAccessToken) {
  nlohmann::json json;
  json["token_type"] = "Bearer";

  EXPECT_THROW(DecodeTokenResponse(json), std::runtime_error);
}

TEST(DecodeTokenResponseTest, ThrowsOnMissingTokenType) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";

  EXPECT_THROW(DecodeTokenResponse(json), std::runtime_error);
}

TEST(DecodeTokenResponseTest, HandlesNonIntegerExpiresIn) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["expires_in"] = "not_a_number";

  // Should not throw, just skip expires_in
  Credentials creds = DecodeTokenResponse(json);

  EXPECT_FALSE(creds.expiresIn.has_value());
  EXPECT_FALSE(creds.expiresAt.has_value());
}

TEST(DecodeTokenResponseTest, HandlesInvalidExpiresAtFormat) {
  nlohmann::json json;
  json["access_token"] = "test_access_token";
  json["token_type"] = "Bearer";
  json["expires_at"] = "invalid-date";
  json["expires_in"] = 3600;

  Credentials creds = DecodeTokenResponse(json);

  // Should fall back to computing from expires_in
  ASSERT_TRUE(creds.expiresAt.has_value());
}

TEST(DecodeTokenResponseTest, DPoPTokenType) {
  // DPoP token type must be preserved exactly as returned by Auth0.
  nlohmann::json json;
  json["access_token"] = "dpop_bound_token";
  json["token_type"]   = "DPoP";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_EQ(creds.accessToken, "dpop_bound_token");
  EXPECT_EQ(creds.tokenType,   "DPoP");
}

TEST(DecodeTokenResponseTest, ZeroExpiresInProducesExpiresAtApproximatelyNow) {
  auto before = std::chrono::system_clock::now();

  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";
  json["expires_in"]   = 0;

  Credentials creds = DecodeTokenResponse(json);

  auto after = std::chrono::system_clock::now();

  ASSERT_TRUE(creds.expiresIn.has_value());
  EXPECT_EQ(creds.expiresIn.value(), 0);
  ASSERT_TRUE(creds.expiresAt.has_value());

  // expiresAt should be very close to the time of the call (now + 0 s).
  auto diff = std::chrono::duration_cast<std::chrono::seconds>(
      creds.expiresAt.value() - before).count();
  EXPECT_GE(diff, 0);
  EXPECT_LE(diff, 2);
}

TEST(DecodeTokenResponseTest, LargeExpiresInOneYear) {
  const int oneYear = 365 * 24 * 3600;

  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";
  json["expires_in"]   = oneYear;

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_TRUE(creds.expiresIn.has_value());
  EXPECT_EQ(creds.expiresIn.value(), oneYear);
  ASSERT_TRUE(creds.expiresAt.has_value());

  auto expected = std::chrono::system_clock::now() + std::chrono::seconds(oneYear);
  auto diff = std::chrono::duration_cast<std::chrono::seconds>(
      creds.expiresAt.value() - expected).count();
  EXPECT_LE(std::abs(diff), 2);
}

TEST(DecodeTokenResponseTest, ScopeWithLeadingAndTrailingSpaces) {
  // istringstream-based parsing skips leading/trailing whitespace.
  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";
  json["scope"]        = "  openid profile  ";

  Credentials creds = DecodeTokenResponse(json);

  ASSERT_EQ(creds.scope.size(), 2u);
  EXPECT_EQ(creds.scope[0], "openid");
  EXPECT_EQ(creds.scope[1], "profile");
}

TEST(DecodeTokenResponseTest, ScopeWithOnlyWhitespaceIsEmpty) {
  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";
  json["scope"]        = "   ";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_TRUE(creds.scope.empty());
}


TEST(DecodeTokenResponseTest, NoExpiryFieldsProducesNoExpiresAt) {
  // When neither expires_at nor expires_in is present, expiresAt must be
  // absent (not guessed or defaulted).
  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_FALSE(creds.expiresIn.has_value());
  EXPECT_FALSE(creds.expiresAt.has_value());
}

TEST(DecodeTokenResponseTest, InvalidExpiresAtWithNoFallbackProducesNoExpiresAt) {
  // Malformed expires_at with no expires_in → no expiry information at all.
  nlohmann::json json;
  json["access_token"] = "tok";
  json["token_type"]   = "Bearer";
  json["expires_at"]   = "not-a-date";

  Credentials creds = DecodeTokenResponse(json);

  EXPECT_FALSE(creds.expiresAt.has_value());
}
