import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

extension FlutterError {
    convenience init(from credentialsManagerError: CredentialsManagerError) {
        var code: String
        switch credentialsManagerError {
        case .noCredentials: code = "NO_CREDENTIALS"
        case .noRefreshToken: code = "NO_REFRESH_TOKEN"
        case .renewFailed: code = "RENEW_FAILED"
        case .storeFailed: code = "STORE_FAILED"
        case .biometricsFailed: code = "BIOMETRICS_FAILED"
        case .revokeFailed: code = "REVOKE_FAILED"
        case .largeMinTTL: code = "LARGE_MIN_TTL"
        default: code = "UNKNOWN"
        }

        self.init(code: code,
                  message: String(describing: credentialsManagerError),
                  details: credentialsManagerError.details)
    }
}
