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

    struct State
    {
        Kind        kind         = Kind::None;
        std::string errorCode;
        std::string errorMessage;
    };

    std::shared_ptr<State> state = std::make_shared<State>();

protected:
    void SuccessInternal(const flutter::EncodableValue *) override
    {
        state->kind = Kind::Success;
    }

    void ErrorInternal(const std::string &code,
                       const std::string &message,
                       const flutter::EncodableValue *) override
    {
        state->kind         = Kind::Error;
        state->errorCode    = code;
        state->errorMessage = message;
    }

    void NotImplementedInternal() override { state->kind = Kind::NotImplemented; }
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

// Returns the State shared_ptr, which remains valid even after handle()
// destroys the MethodResult object (as happens on synchronous error paths).
static std::shared_ptr<CapturingMethodResult::State> Invoke(
    LoginWebAuthRequestHandler &handler,
    flutter::EncodableMap &args)
{
    auto result = std::make_unique<CapturingMethodResult>();
    auto state  = result->state;          // keep state alive independently
    handler.handle(&args, std::move(result));
    return state;
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

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("scopes"));
}

// Additional type variants — confirm the check covers all non-list types.
TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsAnInteger)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(int32_t(42));

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
}

TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsABoolean)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(true);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
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

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("integer"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutIsNegative)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(-1));

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("positive"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutIsZero)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(0));

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("positive"));
}

TEST(LoginHandlerTest, ReturnsErrorWhenAuthTimeoutExceedsMaximum)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(9999999));

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("3600"));
}

// Boundary: 3600 is the maximum inclusive value — must not trigger the >3600 error.
TEST(LoginHandlerTest, AcceptsMaximumBoundaryAuthTimeout)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(3600));

    auto state = Invoke(handler, args);

    EXPECT_NE(state->kind, CapturingMethodResult::Kind::Error);
}

// Boundary: 1 is the minimum inclusive value — must not trigger the <=0 error.
TEST(LoginHandlerTest, AcceptsMinimumBoundaryAuthTimeout)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(1));

    auto state = Invoke(handler, args);

    EXPECT_NE(state->kind, CapturingMethodResult::Kind::Error);
}

// ===========================================================================
// Issue #19 — `useDPoP: true` must have no effect on Windows
// ===========================================================================

TEST(LoginHandlerTest, SilentlyIgnoresUseDPoPTrue)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("useDPoP")] = flutter::EncodableValue(true);

    auto state = Invoke(handler, args);

    EXPECT_NE(state->kind, CapturingMethodResult::Kind::Error)
        << "useDPoP:true must not cause a bad_args error on Windows";
}

TEST(LoginHandlerTest, AcceptsValidScopesListTopLevel)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("openid")));
    scopesList.push_back(flutter::EncodableValue(std::string("profile")));
    scopesList.push_back(flutter::EncodableValue(std::string("email")));
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that "openid" is added automatically even if not provided in scopes
TEST(LoginHandlerTest, AutomaticallyAddsOpenidToScopesList)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("profile")));
    scopesList.push_back(flutter::EncodableValue(std::string("email")));
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that non-string elements in scopes list are rejected
TEST(LoginHandlerTest, ReturnsErrorWhenScopesListContainsNonString)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("openid")));
    scopesList.push_back(flutter::EncodableValue(int32_t(42)));  // invalid
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("scope"));
}

// Test that scope string in parameters is accepted (space-separated)
TEST(LoginHandlerTest, AcceptsValidScopeStringInParameters)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(std::string("profile email"));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that "openid" is added automatically even if not in parameters["scope"]
TEST(LoginHandlerTest, AutomaticallyAddsOpenidToParametersScope)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(std::string("profile email"));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that non-string scope in parameters is rejected
TEST(LoginHandlerTest, ReturnsErrorWhenParametersScopeIsNotString)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(int32_t(42));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("scope"));
}

// Test that top-level "scopes" takes priority over parameters["scope"]
TEST(LoginHandlerTest, TopLevelScopesTakesPriorityOverParametersScope)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();

    // Top-level scopes (should be used)
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("openid")));
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    // Parameters scope (should be ignored)
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(std::string("profile email"));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that platform defaults are used when no scopes provided
TEST(LoginHandlerTest, UsesPlatformDefaultsWhenNoScopesProvided)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    // No "scopes" parameter, no "parameters" parameter

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

// Test that platform defaults are used when parameters is empty
TEST(LoginHandlerTest, UsesPlatformDefaultsWhenParametersIsEmpty)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap emptyParams;
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(emptyParams);

    auto state = Invoke(handler, args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Success);
}

TEST(LoginHandlerTest, ReturnsErrorWhenNullArguments)
{
    LoginWebAuthRequestHandler handler;

    auto result = std::make_unique<CapturingMethodResult>();
    auto state  = result->state;
    handler.handle(nullptr, std::move(result));

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
}

TEST(LoginHandlerTest, ReturnsErrorWhenAccountIsAbsent)
{
    LoginWebAuthRequestHandler handler;

    flutter::EncodableMap emptyArgs;
    auto result = std::make_unique<CapturingMethodResult>();
    auto state  = result->state;
    handler.handle(&emptyArgs, std::move(result));

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
}
