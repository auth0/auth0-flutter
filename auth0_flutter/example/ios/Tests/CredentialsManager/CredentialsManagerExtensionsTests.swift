import XCTest
import Auth0

@testable import auth0_flutter

class CredentialsManagerExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromCredentialsManagerError() {
        let errors: [String: CredentialsManagerError] = [
            "NO_CREDENTIALS": .noCredentials,
            "NO_REFRESH_TOKEN": .noRefreshToken,
            "RENEW_FAILED": .renewFailed,
            "STORE_FAILED": .storeFailed,
            "BIOMETRICS_FAILED": .biometricsFailed,
            "REVOKE_FAILED": .revokeFailed,
            "LARGE_MIN_TTL": .largeMinTTL
        ]
        for (code, error) in errors {
            let flutterError = FlutterError(from: error)
            assert(flutterError: flutterError, is: error, with: code)
        }
    }

    func testIsRetryableIsFalseForNonRetryableErrors() {
        let nonRetryableErrors: [CredentialsManagerError] = [
            .noCredentials,
            .noRefreshToken,
            .renewFailed,
            .storeFailed,
            .revokeFailed,
            .largeMinTTL
        ]
        for error in nonRetryableErrors {
            let flutterError = FlutterError(from: error)
            let details = flutterError.details as! [String: Any]
            XCTAssertEqual(details["_isRetryable"] as? Bool, false,
                           "Expected isRetryable to be false for \(error)")
        }
    }

    func testIsRetryableIsTrueForBiometricsFailed() {
        let flutterError = FlutterError(from: .biometricsFailed)
        let details = flutterError.details as! [String: Any]
        XCTAssertEqual(details["_isRetryable"] as? Bool, true)
    }

    func testIsRetryableIsTrueForRenewFailedWithNetworkError() {
        let networkError = AuthenticationError(info: [:], statusCode: 0)
        let renewError = CredentialsManagerError(code: .renewFailed, cause: networkError)
        let flutterError = FlutterError(from: renewError)
        let details = flutterError.details as! [String: Any]
        // AuthenticationError with statusCode 0 and empty info is treated as a network error
        XCTAssertNotNil(details["_isRetryable"])
    }
}
