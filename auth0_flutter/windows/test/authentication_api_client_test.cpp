#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "../authentication_api_client.h"
#include "../auth0_api_client.h"

using namespace auth0_flutter;

class MockNetworking : public Networking
{
public:
    MOCK_METHOD(NetworkResponse, post,
                (const std::string &path,
                 const web::json::value &body,
                 const std::map<std::string, std::string> &headers),
                (override));
};

static web::json::value MakeTokenResponse()
{
    web::json::value json;
    json[U("access_token")] = web::json::value::string(U("test-access-token"));
    json[U("id_token")] = web::json::value::string(U("test-id-token"));
    json[U("token_type")] = web::json::value::string(U("Bearer"));
    json[U("expires_in")] = web::json::value::number(86400);
    return json;
}

class AuthenticationApiClientTest : public ::testing::Test
{
protected:
    std::shared_ptr<MockNetworking> mockNet = std::make_shared<MockNetworking>();
    std::string headerValue = BuildAuth0ClientHeader("auth0-flutter", "2.1.0");
};

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensSendsAuth0ClientHeader)
{
    std::map<std::string, std::string> capturedHeaders;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const web::json::value &,
                       const std::map<std::string, std::string> &headers) {
            capturedHeaders = headers;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    ASSERT_NE(capturedHeaders.find("Auth0-Client"), capturedHeaders.end());
    EXPECT_EQ(capturedHeaders["Auth0-Client"], headerValue);
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensOmitsHeaderWhenEmpty)
{
    std::map<std::string, std::string> capturedHeaders;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const web::json::value &,
                       const std::map<std::string, std::string> &headers) {
            capturedHeaders = headers;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", "", mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(capturedHeaders.find("Auth0-Client"), capturedHeaders.end());
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensPostsToCorrectPath)
{
    std::string capturedPath;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &path, const web::json::value &,
                       const std::map<std::string, std::string> &) {
            capturedPath = path;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(capturedPath, "/oauth/token");
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensSendsCorrectBody)
{
    web::json::value capturedBody;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const web::json::value &body,
                       const std::map<std::string, std::string> &) {
            capturedBody = body;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(utility::conversions::to_utf8string(capturedBody[U("grant_type")].as_string()), "authorization_code");
    EXPECT_EQ(utility::conversions::to_utf8string(capturedBody[U("client_id")].as_string()), "client123");
    EXPECT_EQ(utility::conversions::to_utf8string(capturedBody[U("code")].as_string()), "auth-code");
    EXPECT_EQ(utility::conversions::to_utf8string(capturedBody[U("redirect_uri")].as_string()), "https://callback");
    EXPECT_EQ(utility::conversions::to_utf8string(capturedBody[U("code_verifier")].as_string()), "verifier");
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensReturnsCredentials)
{
    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([](const std::string &, const web::json::value &,
                      const std::map<std::string, std::string> &) {
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    auto creds = client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(creds.accessToken, "test-access-token");
    EXPECT_EQ(creds.idToken, "test-id-token");
    EXPECT_EQ(creds.tokenType, "Bearer");
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensThrowsOnApiError)
{
    web::json::value errorBody;
    errorBody[U("error")] = web::json::value::string(U("invalid_grant"));
    errorBody[U("error_description")] = web::json::value::string(U("Invalid authorization code"));

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const web::json::value &,
                       const std::map<std::string, std::string> &) {
            return NetworkResponse{403, errorBody};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);

    try
    {
        client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");
        FAIL() << "Expected AuthenticationError";
    }
    catch (const auth0_flutter::AuthenticationError &e)
    {
        EXPECT_EQ(e.GetCode(), "invalid_grant");
        EXPECT_EQ(e.GetStatusCode(), 403);
    }
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensThrowsNetworkErrorOnException)
{
    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([](const std::string &, const web::json::value &,
                      const std::map<std::string, std::string> &) -> NetworkResponse {
            throw std::runtime_error("connection refused");
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);

    try
    {
        client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");
        FAIL() << "Expected AuthenticationError";
    }
    catch (const auth0_flutter::AuthenticationError &e)
    {
        EXPECT_EQ(e.GetCode(), "network_error");
        EXPECT_EQ(e.GetStatusCode(), 0);
        EXPECT_TRUE(e.IsNetworkError());
    }
}
