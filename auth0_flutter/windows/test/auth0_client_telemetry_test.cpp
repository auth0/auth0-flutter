/**
 * @file auth0_client_telemetry_test.cpp
 * @brief Tests for BuildAuth0ClientHeader telemetry helper.
 *
 * Verifies that the Auth0-Client header is correctly base64url-encoded JSON
 * matching the format expected by the Auth0 backend.
 */

#include <gtest/gtest.h>
#include <string>
#include <stdexcept>

#include "../auth0_client.h"

// Minimal base64url decoder for test verification only.
static std::string Base64UrlDecode(const std::string &input)
{
    std::string b64 = input;
    for (auto &c : b64)
    {
        if (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    while (b64.size() % 4 != 0) b64 += '=';

    std::string result;
    for (size_t i = 0; i < b64.size(); i += 4)
    {
        auto val = [](char c) -> int {
            if (c >= 'A' && c <= 'Z') return c - 'A';
            if (c >= 'a' && c <= 'z') return c - 'a' + 26;
            if (c >= '0' && c <= '9') return c - '0' + 52;
            if (c == '+') return 62;
            if (c == '/') return 63;
            return 0;
        };
        int v = (val(b64[i]) << 18) | (val(b64[i+1]) << 12) |
                (val(b64[i+2]) << 6) | val(b64[i+3]);
        result += static_cast<char>((v >> 16) & 0xFF);
        if (b64[i+2] != '=') result += static_cast<char>((v >> 8) & 0xFF);
        if (b64[i+3] != '=') result += static_cast<char>(v & 0xFF);
    }
    return result;
}

TEST(BuildAuth0ClientHeaderTest, IsNotEmpty)
{
    auto header = BuildAuth0ClientHeader("auth0-flutter", "2.1.0");
    EXPECT_FALSE(header.empty());
}

TEST(BuildAuth0ClientHeaderTest, ContainsNoBase64Padding)
{
    auto header = BuildAuth0ClientHeader("auth0-flutter", "2.1.0");
    EXPECT_EQ(header.find('='), std::string::npos) << "Header must not contain base64 padding";
}

TEST(BuildAuth0ClientHeaderTest, ContainsNoStandardBase64Chars)
{
    auto header = BuildAuth0ClientHeader("auth0-flutter", "2.1.0");
    EXPECT_EQ(header.find('+'), std::string::npos) << "'+' must be replaced with '-'";
    EXPECT_EQ(header.find('/'), std::string::npos) << "'/' must be replaced with '_'";
}

TEST(BuildAuth0ClientHeaderTest, DecodestoValidJson)
{
    auto header = BuildAuth0ClientHeader("auth0-flutter", "2.1.0-beta.1");
    auto decoded = Base64UrlDecode(header);

    EXPECT_NE(decoded.find("\"name\""), std::string::npos);
    EXPECT_NE(decoded.find("\"auth0-flutter\""), std::string::npos);
    EXPECT_NE(decoded.find("\"version\""), std::string::npos);
    EXPECT_NE(decoded.find("\"2.1.0-beta.1\""), std::string::npos);
    EXPECT_NE(decoded.find("\"env\""), std::string::npos);
    EXPECT_NE(decoded.find("\"Windows\""), std::string::npos);
}

TEST(BuildAuth0ClientHeaderTest, EmptyNameAndVersionStillProducesValidHeader)
{
    auto header = BuildAuth0ClientHeader("", "");
    EXPECT_FALSE(header.empty());
    auto decoded = Base64UrlDecode(header);
    EXPECT_NE(decoded.find("\"Windows\""), std::string::npos);
}
