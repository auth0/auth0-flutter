/**
 * @file id_token_signature_validator_test.cpp
 * @brief Tests for ValidateIdTokenSignature (non-network validation paths)
 *
 * Covers all validation steps that execute before the JWKS network fetch:
 *   Step 1 – JWT structural validity (SplitJwt / DecodeJwtHeader)
 *   Step 2 – Algorithm must be RS256
 *   Step 3 – Key ID (kid) must be present and non-empty
 *
 * JWKS fetch (step 4) and cryptographic verification (steps 5-6) require
 * a live JWKS endpoint and are therefore exercised in integration tests.
 *
 * Every test uses try/catch rather than EXPECT_THROW so that the exception
 * message is always validated alongside the exception type.
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "../id_token_signature_validator.h"
#include "../id_token_validator.h"

#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

#include <algorithm>
#include <string>

using namespace auth0_flutter;
using ::testing::HasSubstr;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * @brief Base64url-encode a UTF-8 string (no padding).
 *
 * Uses the same OpenSSL BIO pipeline as id_token_validator_test.cpp so that
 * the encoded headers are byte-for-byte identical to what the real JWT library
 * would produce.
 */
static std::string Base64UrlEncode(const std::string &input)
{
    BIO *bio, *b64;
    BUF_MEM *bufferPtr;

    b64  = BIO_new(BIO_f_base64());
    bio  = BIO_new(BIO_s_mem());
    bio  = BIO_push(b64, bio);

    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
    BIO_write(bio, input.data(), static_cast<int>(input.length()));
    BIO_flush(bio);
    BIO_get_mem_ptr(bio, &bufferPtr);

    std::string result(bufferPtr->data, bufferPtr->length);
    BIO_free_all(bio);

    for (auto &c : result)
    {
        if (c == '+') c = '-';
        else if (c == '/') c = '_';
    }
    result.erase(std::remove(result.begin(), result.end(), '='), result.end());
    return result;
}

/**
 * @brief Build a three-part JWT with the given header JSON and a dummy payload/signature.
 */
static std::string MakeJwtWithHeader(
    const std::string &headerJson,
    const std::string &payloadJson = R"({"sub":"test"})")
{
    return Base64UrlEncode(headerJson) + "." +
           Base64UrlEncode(payloadJson) + ".fakesig";
}

// A JWKS URI that is syntactically valid but is never reached in the
// early-exit validation steps tested here.
static const std::string kDummyJwksUri =
    "https://tenant.auth0.com/.well-known/jwks.json";

// Known exact error messages produced by the validator
static const std::string kErrJwtParts =
    "Failed to decode ID token header: JWT must have exactly 3 parts";
static const std::string kErrAlgPrefix =
    "Signature algorithm of \"";
static const std::string kErrAlgSuffix =
    "\" is not supported. Expected the ID token to be signed with \"RS256\"";
static const std::string kErrMissingKid =
    "Could not find a public key for Key ID (kid) \"\"";

// Convenience: builds the full expected algorithm error message.
static std::string AlgError(const std::string &alg)
{
    return kErrAlgPrefix + alg + kErrAlgSuffix;
}


// ===========================================================================
// Step 1 – JWT structural failures
// All produce: "Failed to decode ID token header: JWT must have exactly 3 parts"
// ===========================================================================

TEST(IdTokenSignatureValidatorTest, EmptyTokenThrowsWithStructureMessage)
{
    try
    {
        ValidateIdTokenSignature("", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
}

TEST(IdTokenSignatureValidatorTest, SinglePartTokenThrowsWithStructureMessage)
{
    try
    {
        ValidateIdTokenSignature("onlyonepart", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
}

TEST(IdTokenSignatureValidatorTest, TwoPartTokenThrowsWithStructureMessage)
{
    try
    {
        ValidateIdTokenSignature("header.payload", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
}

TEST(IdTokenSignatureValidatorTest, FourPartTokenThrowsWithStructureMessage)
{
    // Extra dot → SplitJwt rejects anything != 3 parts
    try
    {
        ValidateIdTokenSignature("a.b.c.d", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
}

TEST(IdTokenSignatureValidatorTest, ManyPartTokenThrowsWithStructureMessage)
{
    try
    {
        ValidateIdTokenSignature("not.a.jwt.token.with.too.many.parts", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
}

// ===========================================================================
// Step 1 – JWT header decode failures
// All produce: "Failed to decode ID token header: ..."
// ===========================================================================

TEST(IdTokenSignatureValidatorTest, InvalidBase64InHeaderThrowsDecodeMessage)
{
    // '!' is not a valid base64url character
    try
    {
        ValidateIdTokenSignature("!!!invalid!!!.payload.sig", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        // Inner message is from CryptStringToBinaryA; outer prefix is fixed.
        EXPECT_THAT(std::string(e.what()), HasSubstr("Failed to decode ID token header:"));
        EXPECT_THAT(std::string(e.what()), HasSubstr("Base64 decode failed:"));
    }
}

TEST(IdTokenSignatureValidatorTest, HeaderWithAllDotsInvalidBase64Throws)
{
    // "..." produces three empty parts; decoding an empty base64 string fails
    try
    {
        ValidateIdTokenSignature("...", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_THAT(std::string(e.what()), HasSubstr("Failed to decode ID token header:"));
    }
}

TEST(IdTokenSignatureValidatorTest, HeaderIsValidBase64ButNotJsonThrowsDecodeMessage)
{
    // Encodes a plain string that decodes to non-JSON bytes
    std::string token = Base64UrlEncode("not-json-at-all") + ".payload.sig";
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_THAT(std::string(e.what()), HasSubstr("Failed to decode ID token header:"));
    }
}

TEST(IdTokenSignatureValidatorTest, HeaderIsJsonArrayNotObjectThrowsDecodeMessage)
{
    // A JSON array [] is valid JSON but not a JWT header object; cpprestsdk
    // should reject it when accessing fields, or we catch the parse difference.
    std::string token = Base64UrlEncode("[1,2,3]") + ".payload.sig";
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        // If the validator doesn't throw here (arrays have no "alg" field
        // → treated as missing alg → throws step-2 error), that is also
        // acceptable. Either way it must throw.
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        // Must be one of the two expected prefixes
        const std::string msg = e.what();
        bool isDecodeError = msg.find("Failed to decode ID token header:") != std::string::npos;
        bool isAlgError    = msg.find("is not supported") != std::string::npos;
        EXPECT_TRUE(isDecodeError || isAlgError)
            << "Unexpected error message: " << msg;
    }
}

// ===========================================================================
// Step 2 – Algorithm validation (only RS256 is accepted)
// Error format: Signature algorithm of "<alg>" is not supported.
//               Expected the ID token to be signed with "RS256"
// ===========================================================================

TEST(IdTokenSignatureValidatorTest, HS256AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"HS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("HS256"));
    }
}

TEST(IdTokenSignatureValidatorTest, HS384AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"HS384","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("HS384"));
    }
}

TEST(IdTokenSignatureValidatorTest, HS512AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"HS512","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("HS512"));
    }
}

TEST(IdTokenSignatureValidatorTest, RS384AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS384","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("RS384"));
    }
}

TEST(IdTokenSignatureValidatorTest, RS512AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS512","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("RS512"));
    }
}

TEST(IdTokenSignatureValidatorTest, ES256AlgorithmThrowsExactMessage)
{
    // ECDSA P-256 is valid in other contexts but not accepted here
    std::string token = MakeJwtWithHeader(R"({"alg":"ES256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("ES256"));
    }
}

TEST(IdTokenSignatureValidatorTest, ES384AlgorithmThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"ES384","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("ES384"));
    }
}

TEST(IdTokenSignatureValidatorTest, PS256AlgorithmThrowsExactMessage)
{
    // RSA-PSS variant – different padding scheme, not RS256
    std::string token = MakeJwtWithHeader(R"({"alg":"PS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("PS256"));
    }
}

TEST(IdTokenSignatureValidatorTest, ExplicitNoneAlgorithmThrowsExactMessage)
{
    // "none" is a well-known JWT attack vector; must always be rejected.
    // The alg value "none" is non-empty so the error reports it verbatim.
    std::string token = MakeJwtWithHeader(R"({"alg":"none","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, MissingAlgFieldThrowsNoneMessage)
{
    // Absent "alg" field → internal alg string stays empty → rendered as "none".
    // This produces the same error message as the explicit "none" algorithm.
    std::string token = MakeJwtWithHeader(R"({"typ":"JWT","kid":"keyid-1"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, NumericAlgFieldThrowsNoneMessage)
{
    // is_string() guard skips the numeric value → alg stays empty → "none"
    std::string token = MakeJwtWithHeader(R"({"alg":256,"typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, BooleanAlgFieldThrowsNoneMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":true,"typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, NullAlgFieldThrowsNoneMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":null,"typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, EmptyJsonObjectHeaderThrowsNoneMessage)
{
    // {} has no "alg" field → treated as missing → "none"
    std::string token = MakeJwtWithHeader("{}");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("none"));
    }
}

TEST(IdTokenSignatureValidatorTest, AlgorithmErrorAlwaysMentionsExpectedRS256)
{
    // Regardless of the presented algorithm, the message must tell the developer
    // what IS expected so they know what to fix.
    const std::vector<std::string> badAlgs = {
        "HS256", "HS384", "HS512", "RS384", "RS512", "ES256", "ES384", "PS256", "none"
    };
    for (const auto &alg : badAlgs)
    {
        std::string header = R"({"alg":")" + alg + R"(","typ":"JWT"})";
        std::string token  = MakeJwtWithHeader(header);
        try
        {
            ValidateIdTokenSignature(token, kDummyJwksUri);
            FAIL() << "Expected exception for alg=" << alg;
        }
        catch (const IdTokenValidationException &e)
        {
            EXPECT_THAT(std::string(e.what()), HasSubstr("RS256"))
                << "Error for alg=" << alg << " does not mention RS256";
        }
    }
}

// ===========================================================================
// Step 3 – Key ID (kid) validation
// Error: "Could not find a public key for Key ID (kid) \"\""
// ===========================================================================

TEST(IdTokenSignatureValidatorTest, RS256WithNoKidFieldThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, RS256WithEmptyKidThrowsExactMessage)
{
    // Explicit empty-string kid is treated the same as absent
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT","kid":""})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, RS256WithNumericKidThrowsExactMessage)
{
    // is_string() guard skips numeric kid → kid stays empty
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT","kid":12345})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, RS256WithNullKidThrowsExactMessage)
{
    // JSON null is not a string → kid stays empty
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT","kid":null})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, RS256WithBooleanKidThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT","kid":true})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, RS256WithArrayKidThrowsExactMessage)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT","kid":["k1"]})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
}

TEST(IdTokenSignatureValidatorTest, KidErrorMessageContainsEmptyKidValue)
{
    // The error must embed the empty kid value inside quotes so the developer
    // can see what was received.
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        const std::string msg = e.what();
        EXPECT_THAT(msg, HasSubstr("kid"));
        EXPECT_THAT(msg, HasSubstr("\"\""));   // empty kid is shown as ""
    }
}

// ===========================================================================
// Exception type contract – all failures must throw IdTokenValidationException
// ===========================================================================

TEST(IdTokenSignatureValidatorTest, Step1FailureThrowsIdTokenValidationException)
{
    // Structural failure must not leak std::runtime_error unwrapped
    try
    {
        ValidateIdTokenSignature("onlyone", kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrJwtParts);
    }
    catch (const std::exception &e)
    {
        FAIL() << "Got std::exception instead of IdTokenValidationException: " << e.what();
    }
}

TEST(IdTokenSignatureValidatorTest, Step2FailureThrowsIdTokenValidationException)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"HS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), AlgError("HS256"));
    }
    catch (const std::exception &e)
    {
        FAIL() << "Got std::exception instead of IdTokenValidationException: " << e.what();
    }
}

TEST(IdTokenSignatureValidatorTest, Step3FailureThrowsIdTokenValidationException)
{
    std::string token = MakeJwtWithHeader(R"({"alg":"RS256","typ":"JWT"})");
    try
    {
        ValidateIdTokenSignature(token, kDummyJwksUri);
        FAIL() << "Expected IdTokenValidationException";
    }
    catch (const IdTokenValidationException &e)
    {
        EXPECT_EQ(std::string(e.what()), kErrMissingKid);
    }
    catch (const std::exception &e)
    {
        FAIL() << "Got std::exception instead of IdTokenValidationException: " << e.what();
    }
}
