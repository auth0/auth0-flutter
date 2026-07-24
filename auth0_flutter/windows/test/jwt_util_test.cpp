#include <gtest/gtest.h>

#include "jwt_util.h"

#include <nlohmann/json.hpp>

// Flutter
#include <flutter/encodable_value.h>


/*
 * Helper: Create a minimal valid JWT with a known payload.
 * Header: {"alg":"none"}
 * Payload: {"sub":"123","name":"John","admin":true}
 *
 * NOTE: Signature is empty (allowed by your SplitJwt logic)
 */
static std::string CreateTestJwt() {
  // base64url(header)
  std::string header = "eyJhbGciOiJub25lIn0";
  // base64url(payload)
  std::string payload =
      "eyJzdWIiOiIxMjMiLCJuYW1lIjoiSm9obiIsImFkbWluIjp0cnVlfQ";
  return header + "." + payload + ".";
}

/* ---------------- SplitJwt ---------------- */

TEST(SplitJwtTest, ValidJwtSplitsIntoThreeParts) {
  std::string jwt = "a.b.c";
  JwtParts parts = SplitJwt(jwt);

  EXPECT_EQ(parts.header, "a");
  EXPECT_EQ(parts.payload, "b");
  EXPECT_EQ(parts.signature, "c");
}

TEST(SplitJwtTest, TrailingDotProducesEmptySignature) {
  std::string jwt = "a.b.";
  JwtParts parts = SplitJwt(jwt);

  EXPECT_EQ(parts.header, "a");
  EXPECT_EQ(parts.payload, "b");
  EXPECT_EQ(parts.signature, "");
}

TEST(SplitJwtTest, InvalidJwtThrows) {
  EXPECT_THROW(SplitJwt("only.one"), std::runtime_error);
  EXPECT_THROW(SplitJwt("too.many.parts.here"), std::runtime_error);
}

/* ---------------- DecodeJwtPayload ---------------- */

TEST(DecodeJwtPayloadTest, DecodesPayloadCorrectly) {
  std::string jwt = CreateTestJwt();
  nlohmann::json payload = DecodeJwtPayload(jwt);

  ASSERT_TRUE(payload.is_object());
  EXPECT_EQ(payload.at("sub").get<std::string>(), "123");
  EXPECT_EQ(payload.at("name").get<std::string>(), "John");
  EXPECT_TRUE(payload.at("admin").get<bool>());
}

/* ---------------- JsonToEncodable ---------------- */

TEST(JsonToEncodableTest, ConvertsPrimitiveTypes) {
  EXPECT_TRUE(
      std::holds_alternative<bool>(JsonToEncodable(true)));
  EXPECT_TRUE(
      std::holds_alternative<double>(JsonToEncodable(1.5)));
  EXPECT_TRUE(
      std::holds_alternative<std::string>(
          JsonToEncodable("hello")));
}

TEST(JsonToEncodableTest, ConvertsArray) {
  nlohmann::json arr = nlohmann::json::array({
      1,
      "two",
      true,
  });

  flutter::EncodableValue ev = JsonToEncodable(arr);
  ASSERT_TRUE(std::holds_alternative<flutter::EncodableList>(ev));

  const auto& list = std::get<flutter::EncodableList>(ev);
  EXPECT_EQ(list.size(), 3u);
}

TEST(JsonToEncodableTest, ConvertsObject) {
  nlohmann::json obj;
  obj["a"] = 1;
  obj["b"] = "two";

  flutter::EncodableValue ev = JsonToEncodable(obj);
  ASSERT_TRUE(std::holds_alternative<flutter::EncodableMap>(ev));

  const auto& map = std::get<flutter::EncodableMap>(ev);
  EXPECT_EQ(map.size(), 2u);
}

