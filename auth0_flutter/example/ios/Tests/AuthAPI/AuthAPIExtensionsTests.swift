import XCTest
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import auth0_flutter

class AuthAPIExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromAuthAPIError() throws {
        let errors: [AuthAPIErrorFlag: [String: Any]] = [
            .isMultifactorRequired: ["code": "mfa_required"],
            .isMultifactorEnrollRequired: ["code": "unsupported_challenge_type"],
            .isMultifactorCodeInvalid: ["code": "invalid_grant", "error_description": "Invalid otp_code."],
            .isMultifactorTokenInvalid: ["code": "expired_token", "error_description": "mfa_token is expired"],
            .isPasswordNotStrongEnough: ["code": "invalid_password", "name": "PasswordStrengthError"],
            .isPasswordAlreadyUsed: ["code": "invalid_password", "name": "PasswordHistoryError"],
            .isRuleError: ["code": "unauthorized"],
            .isInvalidCredentials: ["code": "invalid_user_password"],
            .isRefreshTokenDeleted: ["code": "invalid_grant",
                                     "error_description": "The refresh_token was generated for a user who doesn't exist"
                                     + " anymore."],
            .isAccessDenied: ["code": "access_denied"],
            .isTooManyAttempts: ["code": "too_many_attempts"],
            .isVerificationRequired: ["code": "requires_verification"],
            .isPasswordLeaked: ["code": "password_leaked"],
            .isLoginRequired: ["code": "login_required"],
            .isNetworkError: ["cause": URLError(URLError.Code.notConnectedToInternet)],
            .isPasskeyVerificationRetryable: ["code": "invalid_grant",
                                              "auth_session": "test-auth-session",
                                              "verification_required": ["email"]]
        ]
        for (flag, info) in errors {
            let error = AuthenticationError(info: info, statusCode: 400)
            let flutterError = FlutterError(from: error)
            let details = try XCTUnwrap(flutterError.details as? [String: Any])
            let flags = try XCTUnwrap(details[AuthAPIErrorKey.errorFlags] as? [String: Bool])
            assert(flutterError: flutterError, is: error)
            XCTAssertEqual(flags[flag], true)
        }
    }

    func testForwardsPasskeyRetryDataInTheErrorDetails() throws {
        let error = AuthenticationError(info: ["code": "invalid_grant",
                                               "auth_session": "test-auth-session",
                                               "verification_required": ["email", "phone"]],
                                        statusCode: 400)
        let flutterError = FlutterError(from: error)
        let details = try XCTUnwrap(flutterError.details as? [String: Any])
        XCTAssertEqual(details["auth_session"] as? String, "test-auth-session")
        XCTAssertEqual(details["verification_required"] as? [String], ["email", "phone"])
    }

    func testDoesNotFlagAnInvalidGrantWithoutASessionAsPasskeyRetryable() throws {
        let error = AuthenticationError(info: ["code": "invalid_grant"], statusCode: 400)
        let flutterError = FlutterError(from: error)
        let details = try XCTUnwrap(flutterError.details as? [String: Any])
        let flags = try XCTUnwrap(details[AuthAPIErrorKey.errorFlags] as? [String: Bool])
        XCTAssertEqual(flags[AuthAPIErrorFlag.isPasskeyVerificationRetryable], false)
    }
}
