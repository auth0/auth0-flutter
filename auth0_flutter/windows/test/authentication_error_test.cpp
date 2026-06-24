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

/* ------------------------------------------------------------------ */
/* IsPasswordNotStrongEnough                                           */
/* ------------------------------------------------------------------ */

// Requires both error == "invalid_password" AND extra JSON field
// "name" == "PasswordStrengthError".  Only the JSON constructor retains
// extra fields, so the string constructor can never return true.

TEST(AuthenticationErrorClassificationTest, IsPasswordNotStrongEnough_True) {
  web::json::value json;
  json[U("error")]             = web::json::value::string(U("invalid_password"));
  json[U("error_description")] = web::json::value::string(U("Password is too weak."));
  json[U("name")]              = web::json::value::string(U("PasswordStrengthError"));

  AuthenticationError err(json, 400);
  EXPECT_TRUE(err.IsPasswordNotStrongEnough());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordNotStrongEnough_WrongCode) {
  web::json::value json;
  json[U("error")] = web::json::value::string(U("access_denied"));
  json[U("name")]  = web::json::value::string(U("PasswordStrengthError"));

  AuthenticationError err(json, 403);
  EXPECT_FALSE(err.IsPasswordNotStrongEnough());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordNotStrongEnough_WrongName) {
  web::json::value json;
  json[U("error")] = web::json::value::string(U("invalid_password"));
  json[U("name")]  = web::json::value::string(U("SomeOtherError"));

  AuthenticationError err(json, 400);
  EXPECT_FALSE(err.IsPasswordNotStrongEnough());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordNotStrongEnough_NoNameField) {
  // String constructor has no JSON backing, so GetValue("name") returns "".
  AuthenticationError err("invalid_password", "Password is too weak.", 400);
  EXPECT_FALSE(err.IsPasswordNotStrongEnough());
}

/* ------------------------------------------------------------------ */
/* IsPasswordAlreadyUsed                                               */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, IsPasswordAlreadyUsed_True) {
  web::json::value json;
  json[U("error")]             = web::json::value::string(U("invalid_password"));
  json[U("error_description")] = web::json::value::string(U("Password was already used."));
  json[U("name")]              = web::json::value::string(U("PasswordHistoryError"));

  AuthenticationError err(json, 400);
  EXPECT_TRUE(err.IsPasswordAlreadyUsed());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordAlreadyUsed_WrongName) {
  web::json::value json;
  json[U("error")] = web::json::value::string(U("invalid_password"));
  json[U("name")]  = web::json::value::string(U("PasswordStrengthError"));

  AuthenticationError err(json, 400);
  EXPECT_FALSE(err.IsPasswordAlreadyUsed());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordAlreadyUsed_WrongCode) {
  web::json::value json;
  json[U("error")] = web::json::value::string(U("other_error"));
  json[U("name")]  = web::json::value::string(U("PasswordHistoryError"));

  AuthenticationError err(json, 400);
  EXPECT_FALSE(err.IsPasswordAlreadyUsed());
}

TEST(AuthenticationErrorClassificationTest, IsPasswordAlreadyUsed_NoNameField) {
  AuthenticationError err("invalid_password", "Password was already used.", 400);
  EXPECT_FALSE(err.IsPasswordAlreadyUsed());
}

/* ------------------------------------------------------------------ */
/* IsInvalidRefreshToken                                               */
/* ------------------------------------------------------------------ */

// Unlike IsRefreshTokenDeleted, IsInvalidRefreshToken has no status code
// requirement — only the error code and description must match.

TEST(AuthenticationErrorClassificationTest, IsInvalidRefreshToken_True) {
  AuthenticationError err("invalid_grant", "Unknown or invalid refresh token.", 401);
  EXPECT_TRUE(err.IsInvalidRefreshToken());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidRefreshToken_WrongCode) {
  AuthenticationError err("access_denied", "Unknown or invalid refresh token.", 401);
  EXPECT_FALSE(err.IsInvalidRefreshToken());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidRefreshToken_WrongDescription) {
  AuthenticationError err("invalid_grant", "The token has expired.", 401);
  EXPECT_FALSE(err.IsInvalidRefreshToken());
}

TEST(AuthenticationErrorClassificationTest, IsInvalidRefreshToken_AnyStatusCode) {
  // No status code restriction — must be true regardless of HTTP status.
  EXPECT_TRUE(AuthenticationError("invalid_grant",
      "Unknown or invalid refresh token.", 403).IsInvalidRefreshToken());
  EXPECT_TRUE(AuthenticationError("invalid_grant",
      "Unknown or invalid refresh token.", 0).IsInvalidRefreshToken());
  EXPECT_TRUE(AuthenticationError("invalid_grant",
      "Unknown or invalid refresh token.", 500).IsInvalidRefreshToken());
}

/* ------------------------------------------------------------------ */
/* Mutual exclusivity between closely related classifications          */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorClassificationTest, RefreshTokenDeletedAndInvalidAreExclusive) {
  // IsRefreshTokenDeleted: invalid_grant + status 403 + user-deleted description
  AuthenticationError deleted(
      "invalid_grant",
      "The refresh_token was generated for a user who doesn't exist anymore.",
      403);
  EXPECT_TRUE(deleted.IsRefreshTokenDeleted());
  EXPECT_FALSE(deleted.IsInvalidRefreshToken());  // different description

  // IsInvalidRefreshToken: invalid_grant + "Unknown or invalid" description
  AuthenticationError invalid(
      "invalid_grant", "Unknown or invalid refresh token.", 401);
  EXPECT_TRUE(invalid.IsInvalidRefreshToken());
  EXPECT_FALSE(invalid.IsRefreshTokenDeleted());  // different description + status
}

TEST(AuthenticationErrorClassificationTest, PasswordStrengthAndHistoryAreExclusive) {
  web::json::value strengthJson;
  strengthJson[U("error")] = web::json::value::string(U("invalid_password"));
  strengthJson[U("name")]  = web::json::value::string(U("PasswordStrengthError"));
  AuthenticationError strength(strengthJson, 400);
  EXPECT_TRUE(strength.IsPasswordNotStrongEnough());
  EXPECT_FALSE(strength.IsPasswordAlreadyUsed());

  web::json::value historyJson;
  historyJson[U("error")] = web::json::value::string(U("invalid_password"));
  historyJson[U("name")]  = web::json::value::string(U("PasswordHistoryError"));
  AuthenticationError history(historyJson, 400);
  EXPECT_TRUE(history.IsPasswordAlreadyUsed());
  EXPECT_FALSE(history.IsPasswordNotStrongEnough());
}

/* ------------------------------------------------------------------ */
/* JSON constructor — mixed modern + legacy field presence             */
/* ------------------------------------------------------------------ */

TEST(AuthenticationErrorJsonTest, ModernErrorWithLegacyDescriptionField) {
  // "error" present (modern) but "description" instead of "error_description"
  web::json::value json;
  json[U("error")]       = web::json::value::string(U("invalid_grant"));
  json[U("description")] = web::json::value::string(U("Legacy description field."));

  AuthenticationError err(json, 400);
  EXPECT_EQ(err.GetCode(), "invalid_grant");
  // "error_description" is absent so falls back to "description"
  EXPECT_EQ(err.GetDescription(), "Legacy description field.");
}

TEST(AuthenticationErrorJsonTest, BothModernAndLegacyDescriptionPrefersModern) {
  // When both fields are present, "error_description" takes priority.
  web::json::value json;
  json[U("error")]             = web::json::value::string(U("invalid_grant"));
  json[U("error_description")] = web::json::value::string(U("Modern description."));
  json[U("description")]       = web::json::value::string(U("Legacy description."));

  AuthenticationError err(json, 400);
  EXPECT_EQ(err.GetDescription(), "Modern description.");
}

TEST(AuthenticationErrorJsonTest, FallbackDescriptionContainsCode) {
  // When neither description field is present the fallback embeds the code.
  web::json::value json;
  json[U("error")] = web::json::value::string(U("my_error_code"));

  AuthenticationError err(json, 400);
  EXPECT_NE(err.GetDescription().find("my_error_code"), std::string::npos);
}
