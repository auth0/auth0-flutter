package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException

fun AuthenticationException.toMap(): Map<String, Any> {
    val exception = this
    return buildMap {
        put("_statusCode", exception.statusCode)
        put("_errorFlags", mapOf(
            "isMultifactorRequired" to exception.isMultifactorRequired,
            "isMultifactorEnrollRequired" to exception.isMultifactorEnrollRequired,
            "isMultifactorCodeInvalid" to exception.isMultifactorCodeInvalid,
            "isMultifactorTokenInvalid" to exception.isMultifactorTokenInvalid,
            "isPasswordNotStrongEnough" to exception.isPasswordNotStrongEnough,
            "isPasswordAlreadyUsed" to exception.isPasswordAlreadyUsed,
            "isRuleError" to exception.isRuleError,
            "isInvalidCredentials" to exception.isInvalidCredentials,
            "isRefreshTokenDeleted" to exception.isRefreshTokenDeleted,
            "isAccessDenied" to exception.isAccessDenied,
            "isTooManyAttempts" to exception.isTooManyAttempts,
            "isVerificationRequired" to exception.isVerificationRequired,
            "isNetworkError" to exception.isNetworkError,
            "isBrowserAppNotAvailable" to exception.isBrowserAppNotAvailable,
            "isPKCENotAvailable" to exception.isPKCENotAvailable,
            "isInvalidAuthorizeURL" to exception.isInvalidAuthorizeURL,
            "isInvalidConfiguration" to exception.isInvalidConfiguration,
            "isCanceled" to exception.isCanceled,
            "isPasswordLeaked" to exception.isPasswordLeaked,
            "isLoginRequired" to exception.isLoginRequired,
        ))
        if (exception.getValue("mfa_token") != null) { put("mfa_token", exception.getValue("mfa_token")!!) }
    }
}

val AuthenticationException.isTooManyAttempts: Boolean
    get() = "too_many_attempts" == this.getCode()
