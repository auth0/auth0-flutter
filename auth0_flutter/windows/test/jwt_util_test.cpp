#include <gtest/gtest.h>

#include "jwt_util.h"

// cpprestsdk
#include <cpprest/json.h>

// Flutter
#include <flutter/encodable_value.h>

using web::json::value;

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
  value payload = DecodeJwtPayload(jwt);

  ASSERT_TRUE(payload.is_object());
  EXPECT_EQ(payload.at(U("sub")).as_string(), U("123"));
  EXPECT_EQ(payload.at(U("name")).as_string(), U("John"));
  EXPECT_TRUE(payload.at(U("admin")).as_bool());
}

/* ---------------- JsonToEncodable ---------------- */

TEST(JsonToEncodableTest, ConvertsPrimitiveTypes) {
  EXPECT_TRUE(
      std::holds_alternative<bool>(JsonToEncodable(value::boolean(true))));
  EXPECT_TRUE(
      std::holds_alternative<double>(JsonToEncodable(value::number(1.5))));
  EXPECT_TRUE(
      std::holds_alternative<std::string>(
          JsonToEncodable(value::string(U("hello")))));
}

TEST(JsonToEncodableTest, ConvertsArray) {
  value arr = value::array({
      value::number(1),
      value::string(U("two")),
      value::boolean(true),
  });

  flutter::EncodableValue ev = JsonToEncodable(arr);
  ASSERT_TRUE(std::holds_alternative<flutter::EncodableList>(ev));

  const auto& list = std::get<flutter::EncodableList>(ev);
  EXPECT_EQ(list.size(), 3u);
}

TEST(JsonToEncodableTest, ConvertsObject) {
  value obj;
  obj[U("a")] = value::number(1);
  obj[U("b")] = value::string(U("two"));

  flutter::EncodableValue ev = JsonToEncodable(obj);
  ASSERT_TRUE(std::holds_alternative<flutter::EncodableMap>(ev));

  const auto& map = std::get<flutter::EncodableMap>(ev);
  EXPECT_EQ(map.size(), 2u);
}

/* ---------------- ParseJsonToEncodableMap ---------------- */

TEST(ParseJsonToEncodableMapTest, ParsesJsonStringToEncodableMap) {
  std::string json = R"({
    "name": "Alice",
    "age": 30,
    "admin": false
  })";

  flutter::EncodableMap map = ParseJsonToEncodableMap(json);

  EXPECT_EQ(std::get<std::string>(map.at(flutter::EncodableValue("name"))),
            "Alice");
  EXPECT_EQ(std::get<double>(map.at(flutter::EncodableValue("age"))),
            30);
  EXPECT_EQ(std::get<bool>(map.at(flutter::EncodableValue("admin"))),
            false);
}