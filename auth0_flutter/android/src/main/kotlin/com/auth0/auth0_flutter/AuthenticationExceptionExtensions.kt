package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException

fun AuthenticationException.toMap(): Map<String, Any> {
    var ex = this;
    return buildMap<String, Any> {
        put("_statusCode", ex.statusCode)
        put("_errorFlags", mapOf(
            "isMultifactorRequired" to ex.isMultifactorRequired,
            "isMultifactorEnrollRequired" to ex.isMultifactorEnrollRequired,
            "isMultifactorCodeInvalid" to ex.isMultifactorCodeInvalid,
            "isMultifactorTokenInvalid" to ex.isMultifactorTokenInvalid,
            "isPasswordNotStrongEnough" to ex.isPasswordNotStrongEnough,
            "isPasswordAlreadyUsed" to ex.isPasswordAlreadyUsed,
            "isRuleError" to ex.isRuleError,
            "isInvalidCredentials" to ex.isInvalidCredentials,
            "isRefreshTokenDeleted" to ex.isRefreshTokenDeleted,
            "isAccessDenied" to ex.isAccessDenied,
            "isTooManyAttempts" to ex.isTooManyAttempts,
            "isVerificationRequired" to ex.isVerificationRequired,
            "isNetworkError" to ex.isNetworkError,
            "isBrowserAppNotAvailable" to ex.isBrowserAppNotAvailable,
            "isPKCENotAvailable" to ex.isPKCENotAvailable,
            "isInvalidAuthorizeURL" to ex.isInvalidAuthorizeURL,
            "isInvalidConfiguration" to ex.isInvalidConfiguration,
            "isCanceled" to ex.isCanceled,
            "isPasswordLeaked" to ex.isPasswordLeaked,
            "isLoginRequired" to ex.isLoginRequired,
        ))
        if (ex.getValue("mfa_token") != null) { put("mfa_token", ex.getValue("mfa_token")!!) }
    }
}

val AuthenticationException.isTooManyAttempts: Boolean
    get() = "too_many_attempts" == this.getCode()
