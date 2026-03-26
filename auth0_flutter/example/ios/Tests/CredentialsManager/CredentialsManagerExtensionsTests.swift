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

    func testIsRetryableIsFalseForErrorsWithoutNetworkCause() {
        let nonRetryableErrors: [CredentialsManagerError] = [
            .noCredentials,
            .noRefreshToken,
            .renewFailed,
            .storeFailed,
            .biometricsFailed,
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

}
