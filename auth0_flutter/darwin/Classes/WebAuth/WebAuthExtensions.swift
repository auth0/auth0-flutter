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
        case WebAuthError.noBundleIdentifier: code = "NO_BUNDLE_IDENTIFIER"
        case WebAuthError.invalidInvitationURL: code = "INVALID_INVITATION_URL"
        case WebAuthError.userCancelled: code = "USER_CANCELLED"
        case WebAuthError.noAuthorizationCode: code = "NO_AUTHORIZATION_CODE"
        case WebAuthError.pkceNotAllowed: code = "PKCE_NOT_ALLOWED"
        case WebAuthError.idTokenValidationFailed: code = "ID_TOKEN_VALIDATION_FAILED"
        case WebAuthError.transactionActiveAlready: code = "TRANSACTION_ACTIVE_ALREADY"
        case WebAuthError.other: code = "OTHER"
        default: code = "UNKNOWN"
        }
        var details = webAuthError.details
        let isRetryable = (webAuthError.cause as? Auth0APIError)?.isRetryable ?? false
        details["_isRetryable"] = isRetryable
        self.init(code: code, message: String(describing: webAuthError), details: details)
    }
}

