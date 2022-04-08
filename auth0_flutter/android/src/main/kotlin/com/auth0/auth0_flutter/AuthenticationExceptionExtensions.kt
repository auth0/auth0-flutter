package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException

fun AuthenticationException.toMap(): Map<String, Any> {
    return mapOf(
        "_errorFlags" to mapOf(
            "isMultifactorRequired" to this.isMultifactorRequired,
            "isMultifactorEnrollRequired" to this.isMultifactorEnrollRequired,
            "isMultifactorCodeInvalid" to this.isMultifactorCodeInvalid,
            "isMultifactorTokenInvalid" to this.isMultifactorTokenInvalid,
            "isPasswordNotStrongEnough" to this.isPasswordNotStrongEnough,
            "isPasswordAlreadyUsed" to this.isPasswordAlreadyUsed,
            "isRuleError" to this.isRuleError,
            "isInvalidCredentials" to this.isInvalidCredentials,
            "isRefreshTokenDeleted" to this.isRefreshTokenDeleted,
            "isAccessDenied" to this.isAccessDenied,
            "isTooManyAttempts" to this.isTooManyAttempts,
            "isVerificationRequired" to this.isVerificationRequired,
            "isNetworkError" to this.isNetworkError,
            "isBrowserAppNotAvailable" to this.isBrowserAppNotAvailable,
            "isPKCENotAvailable" to this.isPKCENotAvailable,
            "isInvalidAuthorizeURL" to this.isInvalidAuthorizeURL,
            "isInvalidConfiguration" to this.isInvalidConfiguration,
            "isCanceled" to this.isCanceled,
            "isPasswordLeaked" to this.isPasswordLeaked,
            "isLoginRequired" to this.isLoginRequired,
        )
    )
}

val AuthenticationException.isTooManyAttempts: Boolean
    get() = "too_many_attempts" == this.getCode()
