import XCTest
import Auth0

@testable import auth0_flutter

class CredentialsManagerExtensionsTests: XCTestCase {
    func testInitializesFlutterErrorFromCredentialsManagerError() {
        let errors: [String: CredentialsManagerError] = [
            "NO_CREDENTIALS": .noCredentials,
            "NO_REFRESH_TOKEN": .noRefreshToken,
            "RENEW_FAILED": .renewFailed,
            "BIOMETRICS_FAILED": .biometricsFailed,
            "REVOKE_FAILED": .revokeFailed,
            "LARGE_MIN_TTL": .largeMinTTL
        ]
        for (code, error) in errors {
            let flutterError = FlutterError(from: error)
            assert(flutterError: flutterError, is: error, with: code)
        }
    }
}
