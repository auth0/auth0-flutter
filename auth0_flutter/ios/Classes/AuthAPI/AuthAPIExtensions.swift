import Flutter
import Auth0

enum AuthAPIErrorFlag: String, CaseIterable {
    case isMultifactorRequired
    case isMultifactorEnrollRequired
    case isMultifactorCodeInvalid
    case isMultifactorTokenInvalid
    case isPasswordNotStrongEnough
    case isPasswordAlreadyUsed
    case isRuleError
    case isInvalidCredentials
    case isRefreshTokenDeleted
    case isAccessDenied
    case isTooManyAttempts
    case isVerificationRequired
    case isPasswordLeaked
    case isLoginRequired
    case isNetworkError
}

enum AuthAPIErrorKey: String, CaseIterable {
    case errorFlags = "_errorFlags"
    case statusCode = "_statusCode"
}

// MARK: - Extensions

extension FlutterError {
    convenience init(from authenticationError: AuthenticationError) {
        let errorFlags: [String: Bool] = [
            AuthAPIErrorFlag.isMultifactorRequired.rawValue: authenticationError.isMultifactorRequired,
            AuthAPIErrorFlag.isMultifactorEnrollRequired.rawValue: authenticationError.isMultifactorEnrollRequired,
            AuthAPIErrorFlag.isMultifactorCodeInvalid.rawValue: authenticationError.isMultifactorCodeInvalid,
            AuthAPIErrorFlag.isMultifactorTokenInvalid.rawValue: authenticationError.isMultifactorTokenInvalid,
            AuthAPIErrorFlag.isPasswordNotStrongEnough.rawValue: authenticationError.isPasswordNotStrongEnough,
            AuthAPIErrorFlag.isPasswordAlreadyUsed.rawValue: authenticationError.isPasswordAlreadyUsed,
            AuthAPIErrorFlag.isRuleError.rawValue: authenticationError.isRuleError,
            AuthAPIErrorFlag.isInvalidCredentials.rawValue: authenticationError.isInvalidCredentials,
            AuthAPIErrorFlag.isRefreshTokenDeleted.rawValue: authenticationError.isRefreshTokenDeleted,
            AuthAPIErrorFlag.isAccessDenied.rawValue: authenticationError.isAccessDenied,
            AuthAPIErrorFlag.isTooManyAttempts.rawValue: authenticationError.isTooManyAttempts,
            AuthAPIErrorFlag.isVerificationRequired.rawValue: authenticationError.isVerificationRequired,
            AuthAPIErrorFlag.isPasswordLeaked.rawValue: authenticationError.isPasswordLeaked,
            AuthAPIErrorFlag.isLoginRequired.rawValue: authenticationError.isLoginRequired,
            AuthAPIErrorFlag.isNetworkError.rawValue: authenticationError.isNetworkError,
        ]
        var errorDetails = authenticationError.details
        errorDetails[AuthAPIErrorKey.errorFlags] = errorFlags
        errorDetails[AuthAPIErrorKey.statusCode] = authenticationError.statusCode

        self.init(code: authenticationError.code,
                  message: String(describing: authenticationError),
                  details: errorDetails)
    }
}
