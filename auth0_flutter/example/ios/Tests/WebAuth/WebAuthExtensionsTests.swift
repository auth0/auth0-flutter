import XCTest
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import auth0_flutter

class WebAuthExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromWebAuthError() {
        let errors: [String: WebAuthError] = [
            "USER_CANCELLED": .userCancelled,
            "ID_TOKEN_VALIDATION_FAILED": .idTokenValidationFailed,
            "AUTHENTICATION_FAILED": .authenticationFailed,
            "CODE_EXCHANGE_FAILED": .codeExchangeFailed,
            "CREDENTIALS_MANAGER_ERROR": .credentialsManagerError,
            "OTHER": .other,
            "UNKNOWN": .unknown,
            "TRANSACTION_ACTIVE_ALREADY": .transactionActiveAlready
        ]
        for (code, error) in errors {
            let flutterError = FlutterError(from: error)
            assert(flutterError: flutterError, is: error, with: code)
        }
    }

    func testAuthenticationFailedFallsBackWhenNoCause() {
        let flutterError = FlutterError(from: WebAuthError.authenticationFailed)
        XCTAssertEqual(flutterError.code, "AUTHENTICATION_FAILED")
    }

    func testIsRetryableIsFalseForNonNetworkErrors() {
        let nonRetryableErrors: [WebAuthError] = [
            .userCancelled,
            .authenticationFailed,
            .codeExchangeFailed,
            .credentialsManagerError,
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
