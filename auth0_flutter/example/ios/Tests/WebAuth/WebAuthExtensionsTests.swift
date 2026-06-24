import XCTest
import Auth0

@testable import auth0_flutter

class WebAuthExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromWebAuthError() {
        let errors: [String: WebAuthError] = [
            "USER_CANCELLED": .userCancelled,
            "ID_TOKEN_VALIDATION_FAILED": .idTokenValidationFailed,
            "INVALID_INVITATION_URL": .invalidInvitationURL,
            "NO_AUTHORIZATION_CODE": .noAuthorizationCode,
            "NO_BUNDLE_IDENTIFIER": .noBundleIdentifier,
            "PKCE_NOT_ALLOWED": .pkceNotAllowed,
            "OTHER": .other,
            "UNKNOWN": .unknown,
            "TRANSACTION_ACTIVE_ALREADY": .transactionActiveAlready
        ]
        for (code, error) in errors {
            let flutterError = FlutterError(from: error)
            assert(flutterError: flutterError, is: error, with: code)
        }
    }

    func testIsRetryableIsFalseForNonNetworkErrors() {
        let nonRetryableErrors: [WebAuthError] = [
            .userCancelled,
            .noBundleIdentifier,
            .invalidInvitationURL,
            .noAuthorizationCode,
            .pkceNotAllowed,
            .idTokenValidationFailed,
            .transactionActiveAlready,
            .other
        ]
        for error in nonRetryableErrors {
            let flutterError = FlutterError(from: error)
            let details = flutterError.details as! [String: Any]
            XCTAssertEqual(details["_isRetryable"] as? Bool, false,
                           "Expected isRetryable to be false for \(error)")
        }
    }

}
