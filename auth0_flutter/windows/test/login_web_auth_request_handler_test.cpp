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
// For async paths, this waits for a short time for immediate errors (validation failures
// or timeouts waiting for browser callback).
static std::shared_ptr<CapturingMethodResult::State> Invoke(
    flutter::EncodableMap &args)
{
    auto result = std::make_unique<CapturingMethodResult>();
    auto state  = result->state;          // keep state alive independently

    std::mutex wait_mutex;
    std::condition_variable wait_cv;
    bool task_complete = false;

    // Create a custom task runner that signals when tasks complete
    auto task_runner = [&wait_mutex, &wait_cv, &task_complete](std::function<void()> task) {
        task();
        {
            std::unique_lock<std::mutex> lock(wait_mutex);
            task_complete = true;
        }
        wait_cv.notify_all();
    };

    // Use custom handler with task runner that signals completion
    LoginWebAuthRequestHandler handler(task_runner);
    handler.handle(&args, std::move(result));

    // Wait for the task to complete (up to 6 seconds for timeout + overhead)
    // This covers:
    // - Synchronous validation errors (immediate, < 1ms)
    // - Async errors from failed operations (immediate after task starts)
    // - Timeout errors from waitForAuthCode_CustomScheme (default 5 second timeout)
    {
        std::unique_lock<std::mutex> lock(wait_mutex);
        wait_cv.wait_for(lock, std::chrono::seconds(6), [&] { return task_complete; });
    }

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

    auto state = Invoke(args);

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

    auto state = Invoke(args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
}

TEST(LoginHandlerTest, ReturnsErrorWhenScopesIsABoolean)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(true);

    auto state = Invoke(args);

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

    auto state = Invoke(args);

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

    auto state = Invoke(args);

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

    auto state = Invoke(args);

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

    auto state = Invoke(args);

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

    auto state = Invoke(args);

    EXPECT_NE(state->kind, CapturingMethodResult::Kind::Error);
}

// Boundary: 1 is the minimum inclusive value — must not trigger the <=0 error.
TEST(LoginHandlerTest, AcceptsMinimumBoundaryAuthTimeout)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    args[flutter::EncodableValue("authTimeoutSeconds")] =
        flutter::EncodableValue(int32_t(1));

    auto state = Invoke(args);

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

    auto state = Invoke(args);

    EXPECT_NE(state->kind, CapturingMethodResult::Kind::Error)
        << "useDPoP:true must not cause a bad_args error on Windows";
}

TEST(LoginHandlerTest, DISABLED_AcceptsValidScopesListTopLevel)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("openid")));
    scopesList.push_back(flutter::EncodableValue(std::string("profile")));
    scopesList.push_back(flutter::EncodableValue(std::string("email")));
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    // The async flow may timeout waiting for browser callback, but validation itself succeeded.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        // Timeout/cancelled errors are expected in test environment (no browser interaction)
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail for valid scopes";
    }
}

// Test that "openid" is added automatically even if not provided in scopes
TEST(LoginHandlerTest, DISABLED_AutomaticallyAddsOpenidToScopesList)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableList scopesList;
    scopesList.push_back(flutter::EncodableValue(std::string("profile")));
    scopesList.push_back(flutter::EncodableValue(std::string("email")));
    args[flutter::EncodableValue("scopes")] = flutter::EncodableValue(scopesList);

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail for missing openid scope";
    }
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

    auto state = Invoke(args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("scope"));
}

// Test that scope string in parameters is accepted (space-separated)
TEST(LoginHandlerTest, DISABLED_AcceptsValidScopeStringInParameters)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(std::string("profile email"));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail for scope string in parameters";
    }
}

// Test that "openid" is added automatically even if not in parameters["scope"]
TEST(LoginHandlerTest, DISABLED_AutomaticallyAddsOpenidToParametersScope)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(std::string("profile email"));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail for scope in parameters";
    }
}

// Test that non-string scope in parameters is rejected
TEST(LoginHandlerTest, DISABLED_ReturnsErrorWhenParametersScopeIsNotString)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap params;
    params[flutter::EncodableValue("scope")] = flutter::EncodableValue(int32_t(42));
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(params);

    auto state = Invoke(args);

    ASSERT_EQ(state->kind, CapturingMethodResult::Kind::Error);
    EXPECT_EQ(state->errorCode, "bad_args");
    EXPECT_THAT(state->errorMessage, HasSubstr("scope"));
}

// Test that top-level "scopes" takes priority over parameters["scope"]
TEST(LoginHandlerTest, DISABLED_TopLevelScopesTakesPriorityOverParametersScope)
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

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail when both scopes and parameters are valid";
    }
}

// Test that platform defaults are used when no scopes provided
TEST(LoginHandlerTest, DISABLED_UsesPlatformDefaultsWhenNoScopesProvided)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    // No "scopes" parameter, no "parameters" parameter

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail when using platform defaults";
    }
}

// Test that platform defaults are used when parameters is empty
TEST(LoginHandlerTest, DISABLED_UsesPlatformDefaultsWhenParametersIsEmpty)
{
    LoginWebAuthRequestHandler handler;

    auto args = MinimalArgs();
    flutter::EncodableMap emptyParams;
    args[flutter::EncodableValue("parameters")] = flutter::EncodableValue(emptyParams);

    auto state = Invoke(args);

    // Validation passes if we don't get a "bad_args" error.
    ASSERT_NE(state->kind, CapturingMethodResult::Kind::None);
    if (state->kind == CapturingMethodResult::Kind::Error) {
        EXPECT_NE(state->errorCode, "bad_args") << "Validation should not fail when parameters is empty";
    }
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