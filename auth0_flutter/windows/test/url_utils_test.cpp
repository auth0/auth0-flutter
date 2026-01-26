#include <gtest/gtest.h>

#include "url_utils.h"

using namespace auth0_flutter;

/* ---------------- UrlDecode ---------------- */

TEST(UrlDecodeTest, DecodesPercentEncodedCharacters) {
  std::string encoded = "Hello%20World";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "Hello World");
}

TEST(UrlDecodeTest, DecodesPlusAsSpace) {
  std::string encoded = "Hello+World";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "Hello World");
}

TEST(UrlDecodeTest, DecodesSpecialCharacters) {
  std::string encoded = "%21%40%23%24%25%5E%26";  // !@#$%^&
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "!@#$%^&");
}

TEST(UrlDecodeTest, HandlesEmptyString) {
  std::string encoded = "";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "");
}

TEST(UrlDecodeTest, HandlesStringWithoutEncoding) {
  std::string encoded = "HelloWorld";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "HelloWorld");
}

TEST(UrlDecodeTest, HandlesMultipleSpaces) {
  std::string encoded = "Hello%20%20%20World";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "Hello   World");
}

TEST(UrlDecodeTest, HandlesEncodedSlash) {
  std::string encoded = "path%2Fto%2Ffile";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "path/to/file");
}

TEST(UrlDecodeTest, HandlesEncodedEquals) {
  std::string encoded = "key%3Dvalue";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "key=value");
}

TEST(UrlDecodeTest, HandlesMalformedPercentEncoding) {
  // Percent without two hex digits - implementation still decodes partial hex
  std::string encoded = "Hello%2World";
  std::string decoded = UrlDecode(encoded);

  // Implementation decodes %2W as character 0x2, then continues with "orld"
  EXPECT_EQ(decoded, "Hello\x2orld");
}

TEST(UrlDecodeTest, HandlesPercentAtEnd) {
  // Percent at end without hex digits - gets stripped
  std::string encoded = "Hello%";
  std::string decoded = UrlDecode(encoded);

  // Implementation strips the trailing % when it can't find two hex digits
  EXPECT_EQ(decoded, "Hello");
}

TEST(UrlDecodeTest, DecodesUtf8Characters) {
  // UTF-8 encoded emoji (😀)
  std::string encoded = "%F0%9F%98%80";
  std::string decoded = UrlDecode(encoded);

  EXPECT_EQ(decoded, "\xF0\x9F\x98\x80");  // Raw UTF-8 bytes
}

/* ---------------- SafeParseQuery ---------------- */

TEST(SafeParseQueryTest, ParsesSingleKeyValue) {
  std::string query = "key=value";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 1u);
  EXPECT_EQ(params["key"], "value");
}

TEST(SafeParseQueryTest, ParsesMultipleKeyValues) {
  std::string query = "key1=value1&key2=value2&key3=value3";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 3u);
  EXPECT_EQ(params["key1"], "value1");
  EXPECT_EQ(params["key2"], "value2");
  EXPECT_EQ(params["key3"], "value3");
}

TEST(SafeParseQueryTest, ParsesEncodedValues) {
  std::string query = "name=John+Doe&message=Hello%20World";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["name"], "John Doe");
  EXPECT_EQ(params["message"], "Hello World");
}

TEST(SafeParseQueryTest, ParsesEmptyValue) {
  std::string query = "key1=&key2=value2";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["key1"], "");
  EXPECT_EQ(params["key2"], "value2");
}

TEST(SafeParseQueryTest, HandlesEmptyString) {
  std::string query = "";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 0u);
}

TEST(SafeParseQueryTest, HandlesQueryWithoutEquals) {
  std::string query = "invalidquery";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 0u);
}

TEST(SafeParseQueryTest, ParsesEncodedKeys) {
  std::string query = "first%20name=John&last%20name=Doe";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["first name"], "John");
  EXPECT_EQ(params["last name"], "Doe");
}

TEST(SafeParseQueryTest, ParsesSpecialCharactersInValues) {
  std::string query = "redirect_uri=https%3A%2F%2Fexample.com%2Fcallback";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 1u);
  EXPECT_EQ(params["redirect_uri"], "https://example.com/callback");
}

TEST(SafeParseQueryTest, ParsesOAuthCallback) {
  std::string query = "code=abc123&state=xyz789";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["code"], "abc123");
  EXPECT_EQ(params["state"], "xyz789");
}

TEST(SafeParseQueryTest, HandlesTrailingAmpersand) {
  std::string query = "key1=value1&key2=value2&";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["key1"], "value1");
  EXPECT_EQ(params["key2"], "value2");
}

TEST(SafeParseQueryTest, HandlesLeadingAmpersand) {
  std::string query = "&key1=value1&key2=value2";
  auto params = SafeParseQuery(query);

  // Leading & makes first key be "&key1" instead of "key1"
  EXPECT_EQ(params.size(), 2u);
  EXPECT_EQ(params["&key1"], "value1");  // Key includes the leading &
  EXPECT_EQ(params["key2"], "value2");
}

TEST(SafeParseQueryTest, OverwritesDuplicateKeys) {
  std::string query = "key=value1&key=value2";
  auto params = SafeParseQuery(query);

  EXPECT_EQ(params.size(), 1u);
  EXPECT_EQ(params["key"], "value2");  // Last value wins
}
