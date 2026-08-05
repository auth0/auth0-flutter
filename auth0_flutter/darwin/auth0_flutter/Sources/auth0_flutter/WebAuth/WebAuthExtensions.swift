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
        case WebAuthError.userCancelled: code = "USER_CANCELLED"
        case WebAuthError.authenticationFailed: code = "AUTHENTICATION_FAILED"
        case WebAuthError.codeExchangeFailed: code = "CODE_EXCHANGE_FAILED"
        case WebAuthError.idTokenValidationFailed: code = "ID_TOKEN_VALIDATION_FAILED"
        case WebAuthError.credentialsManagerError: code = "CREDENTIALS_MANAGER_ERROR"
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

