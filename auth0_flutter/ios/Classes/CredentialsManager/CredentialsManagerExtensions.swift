import Flutter
import Auth0

extension Array where Element == String {
    var asCommaSeparatedString: String {
        return self.joined(separator: ", ")
    }
}

extension Array where Element: RawRepresentable, Element.RawValue == String {
    var rawValues: [String] {
        return self.map(\.rawValue)
    }
}

extension CaseIterable where Self: RawRepresentable & Requireable, Self.RawValue == String {
    static var requiredCases: [Self] {
        return self.allCases.filter { $0.isRequired }
    }
}

extension FlutterError {
    convenience init(from credentialsManagerError: CredentialsManagerError) {
        var code: String
        switch credentialsManagerError {
        case .noCredentials: code = "NO_CREDENTIALS"
        case .noRefreshToken: code = "NO_REFRESH_TOKEN"
        case .renewFailed: code = "RENEW_FAILED"
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
