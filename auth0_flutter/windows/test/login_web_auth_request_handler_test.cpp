/**
 * @file login_web_auth_request_handler_test.cpp
 * @brief Tests for LoginWebAuthRequestHandler synchronous argument validation
 *
 * Covers only the synchronous validation paths that execute before the pplx
 * background task is launched.  Network, browser, and token exchange paths
 * require integration test infrastructure and are not covered here.
 *
 * Issues addressed:
 *   #15 — null-pointer dereference on non-list `scopes`
 *   #16 — invalid `authTimeoutSeconds` values (wrong type / out-of-range)
 *   #19 — `useDPoP: true` must be silently ignored (no error) on Windows
 */

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "request_handlers/web_auth/login_web_auth_request_handler.h"

#include <flutter/encodable_value.h>
#include <string>

using namespace auth0_flutter;
using ::testing::HasSubstr;

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class CapturingMethodResult
    : public flutter::MethodResult<flutter::EncodableValue>
{
public:
    enum class Kind { None, Success, Error, NotImplemented };

    Kind        kind         = Kind::None;
    std::string errorCode;
    std::string errorMessage;

protected:
    void SuccessInternal(const flutter::EncodableValue *) override
    {
        kind = Kind::Success;
    }

    void ErrorInternal(const std::string &code,
                       const std::string &message,
                       const flutter::EncodableValue *) override
    {
        kind         = Kind::Error;
        errorCode    = code;
        errorMessage = message;
    }

    void NotImplementedInternal() override { kind = Kind::NotImplemented; }
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

static flutter::EncodableMap MinimalArgs()
{
    flutter::EncodableMap account;
    account[flutter::EncodableValue("clientId")] = flutter::EncodableValue(std::string("test_client_id"));
    account[flutter::EncodableValue("domain")]   = flutter::EncodableValue(std::string("test.auth0.com"));

    flutter::EncodableMap args;
    args[flutter::EncodableValue("_account")] = flutter::EncodableValue(account);
    return args;
}

static CapturingMethodResult *Invoke(
    LoginWebAuthRequestHandler &handler,
    flutter::EncodableMap &args)
{
    auto result = std::make_unique<CapturingMethodResult>();
    auto *raw   = result.get();
    handler.handle(&args, std::move(result));
    return raw;
}

// ===========================================================================
// Issue #15 — non-list `scopes` must not crash (null-pointer dereference)
// ===========================================================================

// Primary test — name matches the issue suggestion exactly.
TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsNotAList)
{
    LoginWebAuthRequestHandler handler;

    flutter::EncodableMap args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] =
        flutter::EncodableValue(std::string("openid"));  // string, not list

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
    EXPECT_THAT(raw->errorMessage, HasSubstr("scopes"));
}

// Additional type variants — confirm the check covers all non-list types.
TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsAnInteger)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(int32_t(42));

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
}

TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsABoolean)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(true);

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
}

// ===========================================================================
// Issue #16 — invalid `authTimeoutSeconds` values
// ===========================================================================

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutIsAString)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(std::string("abc"));

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
    EXPECT_THAT(raw->errorMessage, HasSubstr("integer"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutIsNegative)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(-1));

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
    EXPECT_THAT(raw->errorMessage, HasSubstr("positive"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutIsZero)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(0));

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
    EXPECT_THAT(raw->errorMessage, HasSubstr("positive"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutExceedsMaximum)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(9999999));

    auto *raw = Invoke(handler, args);

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
    EXPECT_THAT(raw->errorMessage, HasSubstr("3600"));
}

// Boundary: 3600 is the maximum inclusive value — must not trigger the >3600 error.
TEST(LoginHandlerTest, AcceptsMaximumBoundaryAuthTimeout)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(3600));

    auto *raw = Invoke(handler, args);

    EXPECT_NE(raw->kind, CapturingMethodResult::Kind::Error);
}

// Boundary: 1 is the minimum inclusive value — must not trigger the <=0 error.
TEST(LoginHandlerTest, AcceptsMinimumBoundaryAuthTimeout)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(1));

    auto *raw = Invoke(handler, args);

    EXPECT_NE(raw->kind, CapturingMethodResult::Kind::Error);
}

// ===========================================================================
// Issue #19 — `useDPoP: true` must have no effect on Windows
// ===========================================================================

TEST(LoginHandlerTest, SilentlyIgnoresUseDPoPTrue)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("useDPoP")] = flutter::EncodableValue(true);

    auto *raw = Invoke(handler, args);

    EXPECT_NE(raw->kind, CapturingMethodResult::Kind::Error)
        << "useDPoP:true must not cause a bad_args error on Windows";
}

// ===========================================================================
// Required-field validation
// ===========================================================================

TEST(LoginHandlerTest, ReturnsErrorWhenNullArguments)
{
    LoginWebAuthRequestHandler handler;

    auto result = std::make_unique<CapturingMethodResult>();
    auto *raw   = result.get();
    handler.handle(nullptr, std::move(result));

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
}

TEST(LoginHandlerTest, ReturnsErrorWhenAccountIsAbsent)
{
    LoginWebAuthRequestHandler handler;

    flutter::EncodableMap emptyArgs;
    auto result = std::make_unique<CapturingMethodResult>();
    auto *raw   = result.get();
    handler.handle(&emptyArgs, std::move(result));

    ASSERT_EQ(raw->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(raw->errorCode, "bad_args");
}
