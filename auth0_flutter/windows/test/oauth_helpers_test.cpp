#include <gtest/gtest.h>

#include "oauth_helpers.h"
#include <regex>
#include <openssl/sha.h>

using namespace auth0_flutter;

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

TEST(WaitForAuthCodeCustomSchemeTest, TimeoutReturnsEmptyString) {
  // Test with very short timeout and no environment variable set
  std::string result = waitForAuthCode_CustomScheme("test://callback", 0, "");

  // Should timeout and return empty string
  EXPECT_EQ(result, "");
}

// Note: The HTTP listener-based waitForAuthCode function has been removed.
// The codebase now uses custom scheme callbacks exclusively via
// waitForAuthCode_CustomScheme for all OAuth flows.
