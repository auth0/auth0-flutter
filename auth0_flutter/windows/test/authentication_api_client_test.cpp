#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "../authentication_api_client.h"
#include "../auth0_api_client.h"
#include "../authentication_error.h"

using namespace auth0_flutter;

using HeaderMap = std::map<std::string, std::string>;

class MockNetworking : public Networking
{
public:
    MOCK_METHOD(NetworkResponse, post,
                (const std::string &path,
                 const nlohmann::json &body,
                 const HeaderMap &headers),
                (override));
};

static nlohmann::json MakeTokenResponse()
{
    nlohmann::json json;
    json["access_token"] = "test-access-token";
    json["id_token"] = "test-id-token";
    json["token_type"] = "Bearer";
    json["expires_in"] = 86400;
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
    HeaderMap capturedHeaders;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const nlohmann::json &,
                       const HeaderMap &headers) {
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
    HeaderMap capturedHeaders;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const nlohmann::json &,
                       const HeaderMap &headers) {
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
        .WillOnce([&](const std::string &path, const nlohmann::json &,
                       const HeaderMap &) {
            capturedPath = path;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(capturedPath, "/oauth/token");
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensSendsCorrectBody)
{
    nlohmann::json capturedBody;

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const nlohmann::json &body,
                       const HeaderMap &) {
            capturedBody = body;
            return NetworkResponse{200, MakeTokenResponse()};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);
    client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");

    EXPECT_EQ(capturedBody["grant_type"].get<std::string>(), "authorization_code");
    EXPECT_EQ(capturedBody["client_id"].get<std::string>(), "client123");
    EXPECT_EQ(capturedBody["code"].get<std::string>(), "auth-code");
    EXPECT_EQ(capturedBody["redirect_uri"].get<std::string>(), "https://callback");
    EXPECT_EQ(capturedBody["code_verifier"].get<std::string>(), "verifier");
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensReturnsCredentials)
{
    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([](const std::string &, const nlohmann::json &,
                      const HeaderMap &) {
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
    nlohmann::json errorBody;
    errorBody["error"] = "invalid_grant";
    errorBody["error_description"] = "Invalid authorization code";

    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([&](const std::string &, const nlohmann::json &,
                       const HeaderMap &) {
            return NetworkResponse{403, errorBody};
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);

    try
    {
        client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");
        FAIL() << "Expected AuthenticationError";
    }
    catch (const AuthenticationError &e)
    {
        EXPECT_EQ(e.GetCode(), "invalid_grant");
        EXPECT_EQ(e.GetStatusCode(), 403);
    }
}

TEST_F(AuthenticationApiClientTest, ExchangeCodeForTokensThrowsNetworkErrorOnException)
{
    EXPECT_CALL(*mockNet, post(::testing::_, ::testing::_, ::testing::_))
        .WillOnce([](const std::string &, const nlohmann::json &,
                      const HeaderMap &) -> NetworkResponse {
            throw std::runtime_error("connection refused");
        });

    AuthenticationApiClient client("test.auth0.com", "client123", headerValue, mockNet);

    try
    {
        client.ExchangeCodeForTokens("https://callback", "auth-code", "verifier");
        FAIL() << "Expected AuthenticationError";
    }
    catch (const AuthenticationError &e)
    {
        EXPECT_EQ(e.GetCode(), "network_error");
        EXPECT_EQ(e.GetStatusCode(), 0);
        EXPECT_EQ(e.IsNetworkError(), true);
    }
}
