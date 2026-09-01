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

    func testAuthenticationFailedExtractsUnderlyingServerCode() {
        let serverError = AuthenticationError(info: ["error": "dpop_jkt_mismatch", "error_description": "DPoP thumbprint mismatch"], statusCode: 401)
        let webAuthError = WebAuthError.authenticationFailed(cause: serverError)
        let flutterError = FlutterError(from: webAuthError)
        XCTAssertEqual(flutterError.code, "dpop_jkt_mismatch")
    }

    func testCodeExchangeFailedExtractsUnderlyingServerCode() {
        let serverError = AuthenticationError(info: ["error": "invalid_grant", "error_description": "Code expired"], statusCode: 400)
        let webAuthError = WebAuthError.codeExchangeFailed(cause: serverError)
        let flutterError = FlutterError(from: webAuthError)
        XCTAssertEqual(flutterError.code, "invalid_grant")
    }

    func testAuthenticationFailedFallsBackWhenNoCause() {
        let flutterError = FlutterError(from: WebAuthError.authenticationFailed(cause: NSError(domain: "test", code: 0)))
        XCTAssertEqual(flutterError.code, "AUTHENTICATION_FAILED")
    }

    func testIsRetryableIsFalseForNonNetworkErrors() {
        let nonRetryableErrors: [WebAuthError] = [
            .userCancelled,
            .authenticationFailed(cause: NSError(domain: "test", code: 0)),
            .codeExchangeFailed(cause: NSError(domain: "test", code: 0)),
            .credentialsManagerError(cause: NSError(domain: "test", code: 0)),
            .idTokenValidationFailed(cause: NSError(domain: "test", code: 0)),
            .transactionActiveAlready,
            .other(cause: NSError(domain: "test", code: 0))
        ]
        for error in nonRetryableErrors {
            let flutterError = FlutterError(from: error)
            let details = flutterError.details as! [String: Any]
            XCTAssertEqual(details["_isRetryable"] as? Bool, false,
                           "Expected isRetryable to be false for \(error)")
        }
    }

}
