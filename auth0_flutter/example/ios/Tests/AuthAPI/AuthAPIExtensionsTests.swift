import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPIExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromAuthAPIError() {
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
            .isNetworkError: ["cause": URLError(URLError.Code.notConnectedToInternet)]
        ]
        for (flag, info) in errors {
            let error = AuthenticationError(info: info, statusCode: 400)
            let flutterError = FlutterError(from: error)
            let flags = (flutterError.details as? [String: Any])?[AuthAPIErrorFlag.key] as? [String: Bool]
            assert(flutterError: flutterError, is: error)
            XCTAssertEqual(flags?[flag], true)
        }
    }
}
