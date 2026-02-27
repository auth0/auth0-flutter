#include <gtest/gtest.h>

#include "authentication_error.h"
#include <cpprest/json.h>

using namespace auth0_flutter;

/* ------------------------------------------------------------------ */
/* IsNetworkError                                                       */
/* ------------------------------------------------------------------ */

// Status code 0 means the HTTP request never completed (no connection,
// DNS failure, timeout before any response).  This is the only case
// that should be treated as a network error.
TEST(AuthenticationErrorIsNetworkErrorTest, TrueForStatusCodeZero) {
  AuthenticationError err("network_error", "connection refused", 0);
  EXPECT_TRUE(err.IsNetworkError());
}

// A 5xx response means Auth0 replied — the network was reachable.
// These are server errors, NOT network errors.
TEST(AuthenticationErrorIsNetworkErrorTest, FalseFor500) {
  AuthenticationError err("server_error", "internal server error", 500);
  EXPECT_FALSE(err.IsNetworkError());
}

TEST(AuthenticationErrorIsNetworkErrorTest, FalseFor503) {
  AuthenticationError err("server_error", "service unavailable", 503);
  EXPECT_FALSE(err.IsNetworkError());
}

TEST(AuthenticationErrorIsNetworkErrorTest, FalseFor4xx) {
  AuthenticationError err("invalid_grant", "wrong password", 400);
  EXPECT_FALSE(err.IsNetworkError());

  AuthenticationError err2("access_denied", "unauthorized", 401);
  EXPECT_FALSE(err2.IsNetworkError());

  AuthenticationError err3("access_denied", "forbidden", 403);
  EXPECT_FALSE(err3.IsNetworkError());
}

TEST(AuthenticationErrorIsNetworkErrorTest, FalseFor2xx) {
  AuthenticationError err("unexpected", "should not happen", 200);
  EXPECT_FALSE(err.IsNetworkError());
}

/* ------------------------------------------------------------------ */
/* IsInvalidCredentials                                                 */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_Code) {
  EXPECT_TRUE(AuthenticationError("invalid_user_password", "desc").IsInvalidCredentials());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_WrongEmailOrPassword) {
  EXPECT_TRUE(AuthenticationError("invalid_grant", "Wrong email or password.").IsInvalidCredentials());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_WrongPhoneOrCode) {
  EXPECT_TRUE(
      AuthenticationError("invalid_grant", "Wrong phone number or verification code.")
          .IsInvalidCredentials());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_WrongEmailOrCode) {
  EXPECT_TRUE(
      AuthenticationError("invalid_grant", "Wrong email or verification code.")
          .IsInvalidCredentials());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_OtherDescription) {
  EXPECT_FALSE(AuthenticationError("invalid_grant", "other message").IsInvalidCredentials());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidCredentials_OtherCode) {
  EXPECT_FALSE(AuthenticationError("access_denied", "desc").IsInvalidCredentials());
}

/* ------------------------------------------------------------------ */
/* IsAccessDenied                                                       */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsAccessDenied_True) {
  EXPECT_TRUE(AuthenticationError("access_denied", "desc").IsAccessDenied());
}

TEST(AuthenticationErrorClassificationTest, IsAccessDenied_False) {
  EXPECT_FALSE(AuthenticationError("invalid_grant", "desc").IsAccessDenied());
}

/* ------------------------------------------------------------------ */
/* IsMultifactorRequired                                                */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsMultifactorRequired_MfaRequired) {
  EXPECT_TRUE(AuthenticationError("mfa_required", "desc").IsMultifactorRequired());
}

TEST(AuthenticationErrorClassificationTest, IsMultifactorRequired_A0MfaRequired) {
  EXPECT_TRUE(AuthenticationError("a0.mfa_required", "desc").IsMultifactorRequired());
}

TEST(AuthenticationErrorClassificationTest, IsMultifactorRequired_False) {
  EXPECT_FALSE(AuthenticationError("other_code", "desc").IsMultifactorRequired());
}

/* ------------------------------------------------------------------ */
/* IsRefreshTokenDeleted                                                */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsRefreshTokenDeleted_True) {
  AuthenticationError err(
      "invalid_grant",
      "The refresh_token was generated for a user who doesn't exist anymore.",
      403);
  EXPECT_TRUE(err.IsRefreshTokenDeleted());
}

TEST(AuthenticationErrorClassificationTest, IsRefreshTokenDeleted_WrongStatusCode) {
  AuthenticationError err(
      "invalid_grant",
      "The refresh_token was generated for a user who doesn't exist anymore.",
      401);
  EXPECT_FALSE(err.IsRefreshTokenDeleted());
}

TEST(AuthenticationErrorClassificationTest, IsRefreshTokenDeleted_WrongCode) {
  AuthenticationError err(
      "other_code",
      "The refresh_token was generated for a user who doesn't exist anymore.",
      403);
  EXPECT_FALSE(err.IsRefreshTokenDeleted());
}

/* ------------------------------------------------------------------ */
/* IsPasswordLeaked / IsTooManyAttempts / IsLoginRequired / IsRuleError */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsPasswordLeaked) {
  EXPECT_TRUE(AuthenticationError("password_leaked", "desc").IsPasswordLeaked());
  EXPECT_FALSE(AuthenticationError("other_code", "desc").IsPasswordLeaked());
}

TEST(AuthenticationErrorClassificationTest, IsTooManyAttempts) {
  EXPECT_TRUE(AuthenticationError("too_many_attempts", "desc").IsTooManyAttempts());
  EXPECT_FALSE(AuthenticationError("other_code", "desc").IsTooManyAttempts());
}

TEST(AuthenticationErrorClassificationTest, IsLoginRequired) {
  EXPECT_TRUE(AuthenticationError("login_required", "desc").IsLoginRequired());
  EXPECT_FALSE(AuthenticationError("other_code", "desc").IsLoginRequired());
}

TEST(AuthenticationErrorClassificationTest, IsRuleError) {
  EXPECT_TRUE(AuthenticationError("unauthorized", "desc").IsRuleError());
  EXPECT_FALSE(AuthenticationError("other_code", "desc").IsRuleError());
}

/* ------------------------------------------------------------------ */
/* JSON constructor — modern format (error / error_description)        */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorJsonTest, ParsesModernFormat) {
  web::json::value json;
  json[U("error")]             = web::json::value::string(U("invalid_grant"));
  json[U("error_description")] = web::json::value::string(U("Wrong email or password."));

  AuthenticationError err(json, 400);
  EXPECT_EQ(err.GetCode(),        "invalid_grant");
  EXPECT_EQ(err.GetDescription(), "Wrong email or password.");
  EXPECT_EQ(err.GetStatusCode(),  400);
}

/* ------------------------------------------------------------------ */
/* JSON constructor — legacy format (code / description)               */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorJsonTest, ParsesLegacyFormat) {
  web::json::value json;
  json[U("code")]        = web::json::value::string(U("some_legacy_error"));
  json[U("description")] = web::json::value::string(U("Legacy description."));

  AuthenticationError err(json, 400);
  EXPECT_EQ(err.GetCode(),        "some_legacy_error");
  EXPECT_EQ(err.GetDescription(), "Legacy description.");
}

/* ------------------------------------------------------------------ */
/* JSON constructor — missing fields fall back to UNKNOWN_ERROR         */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorJsonTest, FallsBackToUnknownError) {
  web::json::value json = web::json::value::object();

  AuthenticationError err(json, 500);
  EXPECT_EQ(err.GetCode(),       "UNKNOWN_ERROR");
  EXPECT_EQ(err.GetStatusCode(), 500);
  // Description should embed the fallback code
  EXPECT_NE(err.GetDescription().find("UNKNOWN_ERROR"), std::string::npos);
}

/* ------------------------------------------------------------------ */
/* GetValue — retrieves extra JSON fields (e.g. mfa_token)             */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorJsonTest, GetValueReturnsExtraField) {
  web::json::value json;
  json[U("error")]             = web::json::value::string(U("mfa_required"));
  json[U("error_description")] = web::json::value::string(U("MFA required."));
  json[U("mfa_token")]         = web::json::value::string(U("tok_abc123"));

  AuthenticationError err(json, 403);
  EXPECT_EQ(err.GetValue("mfa_token"),   "tok_abc123");
  EXPECT_EQ(err.GetValue("nonexistent"), "");
}

/* ------------------------------------------------------------------ */
/* GetStatusCode                                                        */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorTest, GetStatusCodeReturnsCorrectValue) {
  EXPECT_EQ(AuthenticationError("code", "desc", 0).GetStatusCode(),   0);
  EXPECT_EQ(AuthenticationError("code", "desc", 400).GetStatusCode(), 400);
  EXPECT_EQ(AuthenticationError("code", "desc", 500).GetStatusCode(), 500);
}
