import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

extension FlutterError {
    convenience init(from webAuthError: WebAuthError) {
        var code: String
        switch webAuthError {
        case .noBundleIdentifier: code = "NO_BUNDLE_IDENTIFIER"
        case .invalidInvitationURL: code = "INVALID_INVITATION_URL"
        case .userCancelled: code = "USER_CANCELLED"
        case .noAuthorizationCode: code = "NO_AUTHORIZATION_CODE"
        case .pkceNotAllowed: code = "PKCE_NOT_ALLOWED"
        case .idTokenValidationFailed: code = "ID_TOKEN_VALIDATION_FAILED"
        case .transactionActiveAlready: code = "TRANSACTION_ACTIVE_ALREADY"
        case .other: code = "OTHER"
        default: code = "UNKNOWN"
        }
        self.init(code: code, message: String(describing: webAuthError), details: webAuthError.details)
    }
}

