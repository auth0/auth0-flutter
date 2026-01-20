#include <gtest/gtest.h>
#include "../id_token_validator.h"
#include <chrono>
#include <cpprest/json.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

using namespace auth0_flutter;

/**
 * @brief Helper to create a simple unsigned JWT for testing
 * Note: These are NOT cryptographically secure - only for validation testing
 */
static std::string CreateTestJWT(const web::json::value &payload)
{
    // Create a simple JWT header
    web::json::value header;
    header[U("alg")] = web::json::value::string(U("HS256"));
    header[U("typ")] = web::json::value::string(U("JWT"));

    std::string headerStr = utility::conversions::to_utf8string(header.serialize());
    std::string payloadStr = utility::conversions::to_utf8string(payload.serialize());

    // Base64 URL encode (simplified - not production quality)
    auto base64UrlEncode = [](const std::string &input) -> std::string
    {
        BIO *bio, *b64;
        BUF_MEM *bufferPtr;

        b64 = BIO_new(BIO_f_base64());
        bio = BIO_new(BIO_s_mem());
        bio = BIO_push(b64, bio);

        BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
        BIO_write(bio, input.data(), static_cast<int>(input.length()));
        BIO_flush(bio);
        BIO_get_mem_ptr(bio, &bufferPtr);

        std::string result(bufferPtr->data, bufferPtr->length);
        BIO_free_all(bio);

        // Convert to URL-safe base64
        for (auto &c : result)
        {
            if (c == '+')
                c = '-';
            else if (c == '/')
                c = '_';
        }
        // Remove padding
        result.erase(std::remove(result.begin(), result.end(), '='), result.end());

        return result;
    };

    std::string encodedHeader = base64UrlEncode(headerStr);
    std::string encodedPayload = base64UrlEncode(payloadStr);

    // Dummy signature for testing
    return encodedHeader + "." + encodedPayload + ".dummy_signature";
}

/**
 * @brief Get current timestamp in seconds
 */
static int64_t GetNow()
{
    auto now = std::chrono::system_clock::now();
    return std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
}

/* ---------------- Valid ID Token Tests ---------------- */

TEST(IdTokenValidatorTest, ValidatesValidToken)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600); // Valid for 1 hour
    payload[U("iat")] = web::json::value::number(now - 10);   // Issued 10 seconds ago
    payload[U("sub")] = web::json::value::string(U("auth0|123"));

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.leeway = 60;

    // Should not throw
    EXPECT_NO_THROW(ValidateIdToken(jwt, config));
}

TEST(IdTokenValidatorTest, ValidatesTokenWithArrayAudience)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));

    // Audience as array
    web::json::value audArray = web::json::value::array();
    audArray[0] = web::json::value::string(U("test_client_id"));
    audArray[1] = web::json::value::string(U("other_audience"));
    payload[U("aud")] = audArray;

    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.leeway = 60;

    EXPECT_NO_THROW(ValidateIdToken(jwt, config));
}

TEST(IdTokenValidatorTest, ValidatesTokenWithLeeway)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now - 30); // Expired 30 seconds ago
    payload[U("iat")] = web::json::value::number(now - 3630);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.leeway = 60; // 60 second leeway should allow this

    EXPECT_NO_THROW(ValidateIdToken(jwt, config));
}

/* ---------------- Invalid Issuer Tests ---------------- */

TEST(IdTokenValidatorTest, RejectsInvalidIssuer)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://evil.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingIssuer)
{
    int64_t now = GetNow();

    web::json::value payload;
    // Missing iss claim
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- Invalid Audience Tests ---------------- */

TEST(IdTokenValidatorTest, RejectsInvalidAudience)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("wrong_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingAudience)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    // Missing aud claim
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsArrayAudienceWithoutMatch)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));

    web::json::value audArray = web::json::value::array();
    audArray[0] = web::json::value::string(U("other_client"));
    audArray[1] = web::json::value::string(U("another_client"));
    payload[U("aud")] = audArray;

    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- Expiration Tests ---------------- */

TEST(IdTokenValidatorTest, RejectsExpiredToken)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now - 120); // Expired 2 minutes ago
    payload[U("iat")] = web::json::value::number(now - 3720);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.leeway = 60; // Only 60 second leeway - should still fail

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingExpiration)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    // Missing exp claim
    payload[U("iat")] = web::json::value::number(now - 10);

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- Issued At Tests ---------------- */

TEST(IdTokenValidatorTest, RejectsTokenIssuedInFuture)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now + 120); // Issued 2 minutes in future

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.leeway = 60; // Only 60 second leeway - should fail

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingIssuedAt)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    // Missing iat claim

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- MaxAge Tests ---------------- */

TEST(IdTokenValidatorTest, ValidatesAuthTimeWithMaxAge)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    payload[U("auth_time")] = web::json::value::number(now - 300); // Authenticated 5 minutes ago

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.maxAge = 600; // Max age 10 minutes - should pass

    EXPECT_NO_THROW(ValidateIdToken(jwt, config));
}

TEST(IdTokenValidatorTest, RejectsOldAuthenticationWithMaxAge)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    payload[U("auth_time")] = web::json::value::number(now - 700); // Authenticated 11.7 minutes ago

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.maxAge = 600;  // Max age 10 minutes
    config.leeway = 60;   // 60 second leeway - total 11 minutes - should still fail

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingAuthTimeWhenMaxAgeSpecified)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    // Missing auth_time

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.maxAge = 600;

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- Nonce Tests ---------------- */

TEST(IdTokenValidatorTest, ValidatesMatchingNonce)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    payload[U("nonce")] = web::json::value::string(U("test_nonce_123"));

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.nonce = "test_nonce_123";

    EXPECT_NO_THROW(ValidateIdToken(jwt, config));
}

TEST(IdTokenValidatorTest, RejectsMismatchedNonce)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    payload[U("nonce")] = web::json::value::string(U("wrong_nonce"));

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.nonce = "test_nonce_123";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMissingNonceWhenExpected)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    // Missing nonce

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";
    config.nonce = "test_nonce_123";

    EXPECT_THROW(
        ValidateIdToken(jwt, config),
        IdTokenValidationException);
}

/* ---------------- Empty/Invalid Token Tests ---------------- */

TEST(IdTokenValidatorTest, RejectsEmptyToken)
{
    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken("", config),
        IdTokenValidationException);
}

TEST(IdTokenValidatorTest, RejectsMalformedToken)
{
    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    EXPECT_THROW(
        ValidateIdToken("not.a.valid.jwt", config),
        IdTokenValidationException);
}

/* ---------------- Payload Output Test ---------------- */

TEST(IdTokenValidatorTest, ReturnsDecodedPayload)
{
    int64_t now = GetNow();

    web::json::value payload;
    payload[U("iss")] = web::json::value::string(U("https://test.auth0.com/"));
    payload[U("aud")] = web::json::value::string(U("test_client_id"));
    payload[U("exp")] = web::json::value::number(now + 3600);
    payload[U("iat")] = web::json::value::number(now - 10);
    payload[U("sub")] = web::json::value::string(U("auth0|123"));
    payload[U("custom_claim")] = web::json::value::string(U("custom_value"));

    std::string jwt = CreateTestJWT(payload);

    IdTokenValidationConfig config;
    config.issuer = "https://test.auth0.com/";
    config.audience = "test_client_id";

    web::json::value outPayload;
    EXPECT_NO_THROW(ValidateIdToken(jwt, config, &outPayload));

    EXPECT_TRUE(outPayload.has_field(U("sub")));
    EXPECT_EQ(
        utility::conversions::to_utf8string(outPayload.at(U("sub")).as_string()),
        "auth0|123");

    EXPECT_TRUE(outPayload.has_field(U("custom_claim")));
    EXPECT_EQ(
        utility::conversions::to_utf8string(outPayload.at(U("custom_claim")).as_string()),
        "custom_value");
}
