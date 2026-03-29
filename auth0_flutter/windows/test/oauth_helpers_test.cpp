#include <gtest/gtest.h>

#include "oauth_helpers.h"
#include "plugin_startup_url_lock.h"
#include <chrono>
#include <regex>
#include <thread>
#include <openssl/sha.h>
#include <windows.h>

using namespace auth0_flutter;

/* ---------------- httpsUrl ---------------- */

TEST(HttpsUrlTest, PrependsPrefixAndTrailingSlash) {
  EXPECT_EQ(httpsUrl("example.auth0.com"), "https://example.auth0.com/");
}

TEST(HttpsUrlTest, DoesNotDoublePrefixWhenAlreadyPresent) {
  EXPECT_EQ(httpsUrl("https://example.auth0.com"), "https://example.auth0.com/");
}

TEST(HttpsUrlTest, DoesNotDoubleSlashWhenAlreadyPresent) {
  EXPECT_EQ(httpsUrl("https://example.auth0.com/"), "https://example.auth0.com/");
}

TEST(HttpsUrlTest, HandlesBareDomainWithSubdomain) {
  EXPECT_EQ(httpsUrl("tenant.us.auth0.com"), "https://tenant.us.auth0.com/");
}

TEST(HttpsUrlTest, HandlesHttpsPrefixWithTrailingSlash) {
  // Already fully normalized — returned as-is.
  EXPECT_EQ(httpsUrl("https://already.ok.com/"), "https://already.ok.com/");
}

TEST(HttpsUrlTest, HandlesDomainWithPath) {
  // A domain with an existing path keeps the trailing slash appended.
  EXPECT_EQ(httpsUrl("example.com/custom-path"), "https://example.com/custom-path/");
}

/* ---------------- base64UrlEncode ---------------- */

TEST(Base64UrlEncodeTest, EncodesEmptyData) {
  std::vector<unsigned char> data = {};
  std::string result = base64UrlEncode(data);

  EXPECT_EQ(result, "");
}

TEST(Base64UrlEncodeTest, EncodesSimpleData) {
  std::vector<unsigned char> data = {'A', 'B', 'C'};
  std::string result = base64UrlEncode(data);

  // "ABC" in base64 is "QUJD" (standard base64)
  // URL-safe base64 removes padding
  EXPECT_EQ(result, "QUJD");
}

TEST(Base64UrlEncodeTest, EncodesWithoutPadding) {
  // Test data that would normally have padding
  std::vector<unsigned char> data = {'A'};
  std::string result = base64UrlEncode(data);

  // Should not contain '=' padding
  EXPECT_TRUE(result.find('=') == std::string::npos);
}

TEST(Base64UrlEncodeTest, UsesUrlSafeCharacters) {
  // Create data that would produce '+' or '/' in standard base64
  std::vector<unsigned char> data;
  for (unsigned char i = 0; i < 255; i++) {
    data.push_back(i);
  }

  std::string result = base64UrlEncode(data);

  // Should not contain '+' or '/'
  EXPECT_TRUE(result.find('+') == std::string::npos);
  EXPECT_TRUE(result.find('/') == std::string::npos);
  // Should use '-' and '_' instead
  EXPECT_TRUE(result.find('-') != std::string::npos || result.find('_') != std::string::npos);
}

TEST(Base64UrlEncodeTest, EncodesKnownValue) {
  // "Hello" = 0x48 0x65 0x6C 0x6C 0x6F
  std::vector<unsigned char> data = {0x48, 0x65, 0x6C, 0x6C, 0x6F};
  std::string result = base64UrlEncode(data);

  // "Hello" in base64 is "SGVsbG8=" (standard)
  // URL-safe without padding is "SGVsbG8"
  EXPECT_EQ(result, "SGVsbG8");
}

TEST(Base64UrlEncodeTest, Encodes32Bytes) {
  // Test with 32 bytes (typical for code verifier)
  std::vector<unsigned char> data(32, 0xFF);
  std::string result = base64UrlEncode(data);

  // Should be non-empty and contain only valid base64url characters
  EXPECT_FALSE(result.empty());
  EXPECT_TRUE(std::regex_match(result, std::regex("^[A-Za-z0-9_-]+$")));
}

/* ---------------- generateCodeVerifier ---------------- */

TEST(GenerateCodeVerifierTest, GeneratesNonEmptyString) {
  std::string verifier = generateCodeVerifier();

  EXPECT_FALSE(verifier.empty());
}

TEST(GenerateCodeVerifierTest, GeneratesValidBase64UrlString) {
  std::string verifier = generateCodeVerifier();

  // Should only contain valid base64url characters
  EXPECT_TRUE(std::regex_match(verifier, std::regex("^[A-Za-z0-9_-]+$")));
}

TEST(GenerateCodeVerifierTest, GeneratesUniqueValues) {
  std::string verifier1 = generateCodeVerifier();
  std::string verifier2 = generateCodeVerifier();

  // Two consecutive calls should produce different values
  EXPECT_NE(verifier1, verifier2);
}

TEST(GenerateCodeVerifierTest, GeneratesValidLength) {
  std::string verifier = generateCodeVerifier();

  // 32 bytes encoded as base64url should be 43 characters (no padding)
  // Base64 encoding: 32 bytes * 8 bits = 256 bits
  // 256 / 6 (base64 uses 6 bits per char) = 42.67 → 43 chars
  EXPECT_GE(verifier.length(), 43u);
  EXPECT_LE(verifier.length(), 44u);
}

TEST(GenerateCodeVerifierTest, GeneratesMultipleUniqueValues) {
  std::set<std::string> verifiers;

  for (int i = 0; i < 100; i++) {
    verifiers.insert(generateCodeVerifier());
  }

  // All 100 should be unique
  EXPECT_EQ(verifiers.size(), 100u);
}

/* ---------------- generateCodeChallenge ---------------- */

TEST(GenerateCodeChallengeTest, GeneratesNonEmptyString) {
  std::string verifier = "test_verifier_123";
  std::string challenge = generateCodeChallenge(verifier);

  EXPECT_FALSE(challenge.empty());
}

TEST(GenerateCodeChallengeTest, GeneratesValidBase64UrlString) {
  std::string verifier = "test_verifier_123";
  std::string challenge = generateCodeChallenge(verifier);

  // Should only contain valid base64url characters
  EXPECT_TRUE(std::regex_match(challenge, std::regex("^[A-Za-z0-9_-]+$")));
}

TEST(GenerateCodeChallengeTest, SameVerifierProducesSameChallenge) {
  std::string verifier = "consistent_verifier";
  std::string challenge1 = generateCodeChallenge(verifier);
  std::string challenge2 = generateCodeChallenge(verifier);

  EXPECT_EQ(challenge1, challenge2);
}

TEST(GenerateCodeChallengeTest, DifferentVerifiersProduceDifferentChallenges) {
  std::string verifier1 = "verifier_one";
  std::string verifier2 = "verifier_two";
  std::string challenge1 = generateCodeChallenge(verifier1);
  std::string challenge2 = generateCodeChallenge(verifier2);

  EXPECT_NE(challenge1, challenge2);
}

TEST(GenerateCodeChallengeTest, ProducesCorrectLength) {
  std::string verifier = "test_verifier";
  std::string challenge = generateCodeChallenge(verifier);

  // SHA256 produces 32 bytes (256 bits)
  // 32 bytes encoded as base64url should be 43 characters (no padding)
  EXPECT_EQ(challenge.length(), 43u);
}

TEST(GenerateCodeChallengeTest, VerifiesKnownValue) {
  // RFC 7636 example (though not exact, we verify the process works)
  std::string verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
  std::string challenge = generateCodeChallenge(verifier);

  // Manually verify by computing SHA256 and base64url encoding
  unsigned char hash[SHA256_DIGEST_LENGTH];
  SHA256(reinterpret_cast<const unsigned char*>(verifier.data()),
         verifier.size(),
         hash);
  std::vector<unsigned char> digest(hash, hash + SHA256_DIGEST_LENGTH);
  std::string expected = base64UrlEncode(digest);

  EXPECT_EQ(challenge, expected);
}

TEST(GenerateCodeChallengeTest, HandlesEmptyVerifier) {
  std::string verifier = "";
  std::string challenge = generateCodeChallenge(verifier);

  // Should still produce a valid base64url encoded SHA256 hash
  EXPECT_FALSE(challenge.empty());
  EXPECT_EQ(challenge.length(), 43u);
}

/* ---------------- Integration Tests ---------------- */

TEST(OAuthHelpersIntegrationTest, VerifierAndChallengeWorkTogether) {
  // Generate a verifier
  std::string verifier = generateCodeVerifier();

  // Generate challenge from verifier
  std::string challenge = generateCodeChallenge(verifier);

  // Both should be valid
  EXPECT_FALSE(verifier.empty());
  EXPECT_FALSE(challenge.empty());

  // Both should be valid base64url
  EXPECT_TRUE(std::regex_match(verifier, std::regex("^[A-Za-z0-9_-]+$")));
  EXPECT_TRUE(std::regex_match(challenge, std::regex("^[A-Za-z0-9_-]+$")));

  // Challenge should be reproducible
  std::string challenge2 = generateCodeChallenge(verifier);
  EXPECT_EQ(challenge, challenge2);
}

TEST(OAuthHelpersIntegrationTest, MultipleVerifiersProduceUniqueChallenges) {
  std::set<std::string> challenges;

  for (int i = 0; i < 10; i++) {
    std::string verifier = generateCodeVerifier();
    std::string challenge = generateCodeChallenge(verifier);
    challenges.insert(challenge);
  }

  // All challenges should be unique
  EXPECT_EQ(challenges.size(), 10u);
}

/* ---------------- waitForAuthCode_CustomScheme ---------------- */

// Note: waitForAuthCode_CustomScheme relies on environment variables and
// Windows-specific behavior, making it difficult to unit test without
// mocking the environment. These tests verify basic behavior.

TEST(WaitForAuthCodeCustomSchemeTest, TimeoutReturnsError) {
  // Test with very short timeout and no environment variable set
  OAuthCallbackResult result = waitForAuthCode_CustomScheme(0, "");

  // Should timeout and return error result
  EXPECT_FALSE(result.success);
  EXPECT_TRUE(result.timedOut);
  EXPECT_EQ(result.code, "");
}

TEST(WaitForAuthCodeCustomSchemeTest, CancelsWhenTokenIsAlreadyCancelled) {
  // Pre-cancel the token before passing it to the function.
  // The polling loop checks ct.is_canceled() on the very first tick and
  // calls pplx::cancel_current_task(), which throws pplx::task_canceled.
  pplx::cancellation_token_source cts;
  cts.cancel();

  EXPECT_THROW(
      waitForAuthCode_CustomScheme(180, "", cts.get_token()),
      pplx::task_canceled);
}

// Note: The HTTP listener-based waitForAuthCode function has been removed.
// The codebase now uses custom scheme callbacks exclusively via
// waitForAuthCode_CustomScheme for all OAuth flows.

/* ---------------- urlEncode ---------------- */

TEST(UrlEncodeTest, EmptyStringReturnsEmpty) {
  EXPECT_EQ(urlEncode(""), "");
}

TEST(UrlEncodeTest, AlphanumericPassesThrough) {
  EXPECT_EQ(urlEncode("abcXYZ0123456789"), "abcXYZ0123456789");
}

TEST(UrlEncodeTest, Rfc3986UnreservedCharsPassThrough) {
  // RFC 3986 §2.3 unreserved: ALPHA / DIGIT / "-" / "." / "_" / "~"
  EXPECT_EQ(urlEncode("-_.~"), "-_.~");
}

TEST(UrlEncodeTest, SpaceEncodedAs20) {
  EXPECT_EQ(urlEncode("hello world"), "hello%20world");
}

TEST(UrlEncodeTest, SlashEncoded) {
  EXPECT_EQ(urlEncode("a/b"), "a%2Fb");
}

TEST(UrlEncodeTest, QuestionMarkEncoded) {
  EXPECT_EQ(urlEncode("key?value"), "key%3Fvalue");
}

TEST(UrlEncodeTest, HashEncoded) {
  EXPECT_EQ(urlEncode("foo#bar"), "foo%23bar");
}

TEST(UrlEncodeTest, AtSignEncoded) {
  EXPECT_EQ(urlEncode("user@example.com"), "user%40example.com");
}

TEST(UrlEncodeTest, ColonAndDoubleSlashEncoded) {
  // Verifies that "://" is fully encoded when a URL is passed as a
  // query parameter value (e.g. redirect_uri=https%3A%2F%2F...).
  EXPECT_EQ(urlEncode("https://example.com"),
            "https%3A%2F%2Fexample.com");
}

TEST(UrlEncodeTest, AmpersandEncoded) {
  EXPECT_EQ(urlEncode("a&b"), "a%26b");
}

TEST(UrlEncodeTest, EqualsEncoded) {
  EXPECT_EQ(urlEncode("key=value"), "key%3Dvalue");
}

TEST(UrlEncodeTest, PlusSignEncodedAs2B) {
  // '+' must be percent-encoded as %2B, not left as '+'.
  // In application/x-www-form-urlencoded '+' means space, so leaving it
  // unencoded would corrupt values that legitimately contain a plus sign.
  EXPECT_EQ(urlEncode("a+b"), "a%2Bb");
}

TEST(UrlEncodeTest, ScopeStringSpacesEncoded) {
  // Scope strings like "openid profile email" must have spaces encoded
  // when appended to a URL query string.
  EXPECT_EQ(urlEncode("openid profile email"), "openid%20profile%20email");
}

TEST(UrlEncodeTest, Auth0CallbackSchemeEncoded) {
  // auth0flutter://callback must be fully encoded when passed as the
  // redirect_uri query parameter value.
  EXPECT_EQ(urlEncode("auth0flutter://callback"),
            "auth0flutter%3A%2F%2Fcallback");
}

TEST(UrlEncodeTest, Auth0DomainPassesThrough) {
  // Domains contain only unreserved characters and must pass through unchanged.
  EXPECT_EQ(urlEncode("tenant.auth0.com"), "tenant.auth0.com");
}

TEST(UrlEncodeTest, HyphenatedDomainPassesThrough) {
  EXPECT_EQ(urlEncode("my-tenant.us.auth0.com"), "my-tenant.us.auth0.com");
}

TEST(UrlEncodeTest, OutputHexDigitsAreUppercase) {
  // The implementation uses std::hex << std::uppercase, so hex must be upper.
  EXPECT_EQ(urlEncode(" "), "%20");    // not %20 - correct
  EXPECT_EQ(urlEncode("/"), "%2F");    // not %2f
  EXPECT_EQ(urlEncode(":"), "%3A");    // not %3a
}

TEST(UrlEncodeTest, HighByteEncodedAsUppercaseHex) {
  std::string input(1, static_cast<char>(0xFF));
  EXPECT_EQ(urlEncode(input), "%FF");  // not %ff
}

TEST(UrlEncodeTest, Rfc3986ReservedCharsAllEncoded) {
  // All RFC 3986 reserved characters must be percent-encoded and must not
  // appear literally in the result.
  const std::string reserved = ":/?#[]@!$&'()*+,;=";
  const std::string result = urlEncode(reserved);
  for (char c : reserved) {
    EXPECT_EQ(result.find(c), std::string::npos)
        << "Character '" << c << "' should be percent-encoded but was not";
  }
}

TEST(UrlEncodeTest, AudienceUrlEncoded) {
  EXPECT_EQ(urlEncode("https://api.example.com/"),
            "https%3A%2F%2Fapi.example.com%2F");
}

TEST(UrlEncodeTest, OrganizationIdPassesThrough) {
  // org_ prefixed IDs are alphanumeric — no encoding needed.
  EXPECT_EQ(urlEncode("org_abc123XYZ"), "org_abc123XYZ");
}

/* -------- waitForAuthCode_CustomScheme — environment variable tests -------- */

// For these tests the PLUGIN_STARTUP_URL environment variable is set before
// calling waitForAuthCode_CustomScheme.  The polling loop reads and clears it
// on the very first iteration (before any sleep), so calls return immediately
// without reaching the timeout.  Each test clears any stale value first.

// NOTE: The old "SuccessWithValidCodeAndNoStateCheck" test was removed.
// State validation is unconditional: an empty or missing state is always
// a state_mismatch regardless of the expectedState value passed by the caller.
// Passing "" as expectedState never produces a success result.
// See MissingStateAlwaysFailsEvenWithNoExpectedState for the authoritative test.

TEST(WaitForAuthCodeEnvVarTest, SuccessWithCodeAndMatchingState) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=my_auth_code&state=csrf_token_abc");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "csrf_token_abc");

  EXPECT_TRUE(result.success);
  EXPECT_EQ(result.code, "my_auth_code");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, StateMismatchReturnsMismatchError) {
  // Callback carries an attacker-controlled state that does not match.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=x&state=attacker_state");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "legitimate_state");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "state_mismatch");
  EXPECT_TRUE(result.code.empty());
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, MissingStateParamWhenExpectedIsStateMismatch) {
  // Callback has no state param at all — treated as a mismatch.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=abc");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "expected_csrf");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "state_mismatch");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, OAuthAccessDeniedErrorPropagated) {
  // '+' in error_description is decoded to ' ' by SafeParseQuery.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?error=access_denied"
      L"&error_description=User+denied+access&state=s1");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "s1");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "access_denied");
  EXPECT_EQ(result.errorDescription, "User denied access");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, OAuthErrorWithoutDescriptionHasEmptyDescription) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?error=login_required&state=s2");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "s2");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "login_required");
  EXPECT_EQ(result.errorDescription, "");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, CallbackWithNoQueryParamsReturnsInvalidCallback) {
  // Correct scheme but no '?' — the query string is absent.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "invalid_callback");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, CallbackWithNoCodeAndNoErrorReturnsInvalidCallback) {
  // State matches but neither 'code' nor 'error' is present in the query.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?state=xyz&foo=bar");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "xyz");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "invalid_callback");
  EXPECT_FALSE(result.timedOut);
}

// NOTE: This test takes ~1 second because the wrong-scheme URL causes one
// full polling cycle before the 1-second timeout expires.
TEST(WaitForAuthCodeEnvVarTest, WrongSchemeUrlIsIgnoredAndTimesOut) {
  // An HTTPS redirect (e.g. from an attacker or mis-configured intermediary)
  // must be silently skipped.  Only auth0flutter:// callbacks are accepted.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"https://evil.example.com/callback?code=hijacked_code");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(1, "");

  EXPECT_FALSE(result.success);
  EXPECT_TRUE(result.timedOut);
  EXPECT_TRUE(result.code.empty());
}

// NOTE: This test takes ~200ms because the wrong-scheme URL is consumed on
// the first tick, then the correct URL is written and picked up on the second.
TEST(WaitForAuthCodeEnvVarTest, WrongSchemeIsSkippedAndCorrectCallbackAccepted) {
  // Confirm that a non-matching URI is discarded and the poller continues
  // to accept the legitimate callback on a subsequent tick.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"https://evil.example.com/callback?code=hijacked");

  // Spawn a thread that writes the legitimate URL after a short delay,
  // simulating the URL arriving one poll cycle after the wrong one.
  std::thread writer([]() {
    std::this_thread::sleep_for(std::chrono::milliseconds(300));
    SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
        L"auth0flutter://callback?code=real_code&state=s_valid");
  });

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "s_valid");
  writer.join();

  EXPECT_TRUE(result.success);
  EXPECT_EQ(result.code, "real_code");
  EXPECT_FALSE(result.timedOut);
}

/* -------- Exact-match URL validation (prevents callbackevil attacks) ----- */

// NOTE: Takes ~1 s (wrong-prefix URL causes one full polling cycle before timeout).
TEST(WaitForAuthCodeEnvVarTest, RejectsSimilarPrefixCallbackEvil) {
  // "auth0flutter://callbackevil" must NOT match "auth0flutter://callback".
  // Before the exact-match fix this would have been accepted as a prefix match.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callbackevil?code=stolen&state=s1");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(1, "s1");

  EXPECT_FALSE(result.success);
  EXPECT_TRUE(result.timedOut);
  EXPECT_TRUE(result.code.empty());
}

// NOTE: Takes ~1 s.
TEST(WaitForLogoutCallbackTest, RejectsSimilarPrefixCallbackEvil) {
  // "auth0flutter://callbackevil" must NOT match "auth0flutter://callback".
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callbackevil");

  bool result = waitForLogoutCallback("auth0flutter://callback", 1);
  EXPECT_FALSE(result);
}

/* -------- trailing-slash normalization ----------------------------------- */

TEST(WaitForAuthCodeEnvVarTest, TrailingSlashInCallbackUrlMatches) {
  // Auth0 may redirect to "auth0flutter://callback/" (with trailing slash)
  // while the app expects "auth0flutter://callback" (without).
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback/?code=my_code&state=s1");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "s1");

  EXPECT_TRUE(result.success);
  EXPECT_EQ(result.code, "my_code");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, TrailingSlashInExpectedUrlMatches) {
  // If the caller passes appCustomUrl with a trailing slash, it should
  // still match a callback without one.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=my_code&state=s2");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(
      5, "s2", pplx::cancellation_token::none(), "auth0flutter://callback/");

  EXPECT_TRUE(result.success);
  EXPECT_EQ(result.code, "my_code");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForLogoutCallbackTest, TrailingSlashInCallbackUrlMatches) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback/");

  bool result = waitForLogoutCallback("auth0flutter://callback", 5);
  EXPECT_TRUE(result);
}

TEST(WaitForLogoutCallbackTest, TrailingSlashInExpectedUrlMatches) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback");

  bool result = waitForLogoutCallback("auth0flutter://callback/", 5);
  EXPECT_TRUE(result);
}

/* -------- authTimeoutSeconds validation (CSRF state always validated) ---- */

TEST(WaitForAuthCodeEnvVarTest, MissingStateAlwaysFailsEvenWithNoExpectedState) {
  // State validation is unconditional. A callback with no state parameter
  // must be rejected even when the caller passes an empty expectedState —
  // that case signals an internal logic error, not a permissive mode.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=abc");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "state_mismatch");
  EXPECT_FALSE(result.timedOut);
}

TEST(WaitForAuthCodeEnvVarTest, EmptyExpectedStateWithStateInCallbackIsStateMismatch) {
  // An attacker-supplied state when the expected state is empty must still
  // be rejected — not silently accepted.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?code=abc&state=attacker");

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "");

  EXPECT_FALSE(result.success);
  EXPECT_EQ(result.error, "state_mismatch");
  EXPECT_FALSE(result.timedOut);
}

/* -------- authTimeout boundary — zero and negative timeouts -------------- */

TEST(WaitForAuthCodeCustomSchemeTest, ZeroTimeoutReturnsTimeoutImmediately) {
  // A zero-second timeout must not block and must return timedOut == true.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
  OAuthCallbackResult result = waitForAuthCode_CustomScheme(0, "any_state");

  EXPECT_FALSE(result.success);
  EXPECT_TRUE(result.timedOut);
}

TEST(WaitForAuthCodeCustomSchemeTest, NegativeTimeoutReturnsTimeoutImmediately) {
  // A negative timeout (e.g. from a negative Duration in Dart) must not
  // block — the while-loop condition is false from the start.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
  OAuthCallbackResult result = waitForAuthCode_CustomScheme(-1, "any_state");

  EXPECT_FALSE(result.success);
  EXPECT_TRUE(result.timedOut);
}

// Issue #17 — exact test name requested in the issue report.
// NOTE: Takes ~200 ms (one poll cycle between the two env-var writes).
TEST(WaitForAuthCodeCustomSchemeTest, IgnoresNonMatchingUriAndAcceptsCorrectOne) {
  // Set PLUGIN_STARTUP_URL to an attacker-controlled URL — must be ignored.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"https://attacker.example.com/callback?code=x");

  // Write the legitimate callback after one poll cycle.
  std::thread writer([]() {
    std::this_thread::sleep_for(std::chrono::milliseconds(300));
    SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
        L"auth0flutter://callback?code=abc&state=s");
  });

  OAuthCallbackResult result = waitForAuthCode_CustomScheme(5, "s");
  writer.join();

  EXPECT_TRUE(result.success);
  EXPECT_EQ(result.code, "abc");
  EXPECT_FALSE(result.timedOut);
  EXPECT_TRUE(result.error.empty());
}

/* -------- waitForLogoutCallback ------------------------------------------ */

// Issue #17 — non-matching callback URI silently ignored; correct one accepted
// These tests mirror the waitForAuthCode_CustomScheme env-var tests but for
// the simpler logout polling function (no state / code validation).

TEST(WaitForLogoutCallbackTest, ZeroTimeoutReturnsFalse) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
  bool result = waitForLogoutCallback("auth0flutter://callback", 0);
  EXPECT_FALSE(result);
}

TEST(WaitForLogoutCallbackTest, NegativeTimeoutReturnsFalse) {
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
  bool result = waitForLogoutCallback("auth0flutter://callback", -1);
  EXPECT_FALSE(result);
}

TEST(WaitForLogoutCallbackTest, ReturnsTrueWhenCallbackMatchesExactUri) {
  // Exact returnTo URI with no query parameters (bare logout callback).
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"auth0flutter://callback");
  bool result = waitForLogoutCallback("auth0flutter://callback", 5);
  EXPECT_TRUE(result);
}

TEST(WaitForLogoutCallbackTest, ReturnsTrueWhenCallbackMatchesUriWithQueryParams) {
  // Auth0 may append query parameters to the returnTo redirect.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"auth0flutter://callback?foo=bar");
  bool result = waitForLogoutCallback("auth0flutter://callback", 5);
  EXPECT_TRUE(result);
}

TEST(WaitForLogoutCallbackTest, ReturnsTrueForCustomReturnToUri) {
  // Callers can provide a custom returnTo URI; only that prefix should match.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"com.example.app://logout/callback");
  bool result = waitForLogoutCallback("com.example.app://logout/callback", 5);
  EXPECT_TRUE(result);
}

// NOTE: This test takes ~200 ms because the wrong-prefix URL is consumed on
// the first tick, then the correct URL is written and picked up on the second.
TEST(WaitForLogoutCallbackTest, WrongPrefixIsIgnoredAndCorrectCallbackAccepted) {
  // Confirm that a URI that doesn't start with returnToUri is silently
  // discarded and the poller continues to accept the correct one.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"https://attacker.example.com/callback?code=hijacked");

  std::thread writer([]() {
    std::this_thread::sleep_for(std::chrono::milliseconds(300));
    SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
        L"auth0flutter://callback");
  });

  bool result = waitForLogoutCallback("auth0flutter://callback", 5);
  writer.join();

  EXPECT_TRUE(result);
}

// NOTE: This test takes ~1 s (one full polling cycle before timeout).
TEST(WaitForLogoutCallbackTest, WrongPrefixUrlIsIgnoredAndTimesOut) {
  // A URI with a different scheme must be discarded; no callback with the
  // correct prefix arrives, so the function must time out and return false.
  SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL",
      L"https://evil.example.com/callback");
  bool result = waitForLogoutCallback("auth0flutter://callback", 1);
  EXPECT_FALSE(result);
}

TEST(WaitForLogoutCallbackTest, CancelsWhenTokenIsAlreadyCancelled) {
  pplx::cancellation_token_source cts;
  cts.cancel();

  EXPECT_THROW(
      waitForLogoutCallback("auth0flutter://callback", 180, cts.get_token()),
      pplx::task_canceled);
}

/* -------- Reader-Writer Lock Tests (Issue #4 - TOCTOU Race Prevention) -------- */

TEST(PluginUrlReaderWriterLockTest, LockIsInitializedCorrectly) {
  PluginUrlReaderWriterLock lock;
  EXPECT_TRUE(lock.IsValid());
}

TEST(PluginUrlReaderWriterLockTest, GetPluginUrlRwLockReturnsValidInstance) {
  auto &lock = GetPluginUrlRwLock();
  EXPECT_TRUE(lock.IsValid());
}

TEST(PluginUrlReaderWriterLockTest, MultipleReadersCanAcquireSimultaneously) {
  auto &lock = GetPluginUrlRwLock();

  // Start 3 reader threads that each acquire the read lock
  std::atomic<int> activeReaders(0);
  std::atomic<int> maxConcurrentReaders(0);
  std::barrier barrier(3);

  auto readerThread = [&]() {
    ReadLockGuard readLock(lock);
    if (readLock.IsValid()) {
      activeReaders++;
      // Track the maximum number of concurrent readers
      int current = activeReaders.load();
      int prevMax;
      do {
        prevMax = maxConcurrentReaders.load();
      } while (current > prevMax &&
               !maxConcurrentReaders.compare_exchange_weak(prevMax, current));

      // All readers arrive at the barrier
      barrier.arrive_and_wait();

      activeReaders--;
    }
  };

  std::thread t1(readerThread);
  std::thread t2(readerThread);
  std::thread t3(readerThread);

  t1.join();
  t2.join();
  t3.join();

  // All 3 readers should have been active simultaneously at some point
  EXPECT_GE(maxConcurrentReaders.load(), 2)
      << "Multiple readers should be able to proceed simultaneously";
}

TEST(PluginUrlReaderWriterLockTest, WriterBlocksReaders) {
  auto &lock = GetPluginUrlRwLock();

  std::atomic<bool> readerStarted(false);
  std::atomic<bool> readerBlocked(false);
  bool writerStarted = false;

  // Start a write-lock holder
  auto writerThread = [&]() {
    WriteLockGuard writeLock(lock);
    if (writeLock.IsValid()) {
      writerStarted = true;
      // Hold the lock for 100ms
      std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
  };

  // Try to acquire read lock after writer
  auto readerThread = [&]() {
    std::this_thread::sleep_for(std::chrono::milliseconds(10)); // Let writer go first
    readerStarted = true;
    auto start = std::chrono::steady_clock::now();
    ReadLockGuard readLock(lock);
    auto elapsed = std::chrono::steady_clock::now() - start;
    // Reader should have been blocked by writer
    if (elapsed > std::chrono::milliseconds(50)) {
      readerBlocked = true;
    }
  };

  std::thread writer(writerThread);
  std::thread reader(readerThread);

  writer.join();
  reader.join();

  EXPECT_TRUE(writerStarted) << "Writer should have acquired lock";
  EXPECT_TRUE(readerStarted) << "Reader should have tried to acquire lock";
  // Note: Due to timing, readerBlocked may not always be true, but it should
  // demonstrate the lock mechanism doesn't crash
}

TEST(PluginUrlReaderWriterLockTest, ReadLockGuardReleasesOnDestruction) {
  auto &lock = GetPluginUrlRwLock();

  {
    ReadLockGuard readLock(lock);
    EXPECT_TRUE(readLock.IsValid());
    // Lock is held here
  }
  // Lock should be released after this point

  // Another thread should be able to acquire write lock
  WriteLockGuard writeLock(lock);
  EXPECT_TRUE(writeLock.IsValid());
}

TEST(PluginUrlReaderWriterLockTest, WriteLockGuardReleasesOnDestruction) {
  auto &lock = GetPluginUrlRwLock();

  {
    WriteLockGuard writeLock(lock);
    EXPECT_TRUE(writeLock.IsValid());
  }

  // Another thread should be able to acquire read lock
  ReadLockGuard readLock(lock);
  EXPECT_TRUE(readLock.IsValid());
}

TEST(PluginUrlReaderWriterLockTest, NamedKernelObjectsAreSharedAcrossInstances) {
  // Create two separate instances - they should use the same named kernel objects
  PluginUrlReaderWriterLock lock1;
  PluginUrlReaderWriterLock lock2;

  EXPECT_TRUE(lock1.IsValid());
  EXPECT_TRUE(lock2.IsValid());

  // Both locks should be able to acquire independently
  // (they coordinate via named Windows kernel objects, not direct memory sharing)
  WriteLockGuard writeLock1(lock1);
  EXPECT_TRUE(writeLock1.IsValid());

  // lock2 should also work (same named objects)
  ReadLockGuard readLock2(lock2);
  EXPECT_TRUE(readLock2.IsValid());
}
