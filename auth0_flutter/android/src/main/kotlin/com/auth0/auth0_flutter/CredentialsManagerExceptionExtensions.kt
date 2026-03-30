package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.storage.CredentialsManagerException

fun CredentialsManagerException.toMap(): Map<String, Any> {
    val exceptionCause = this.cause
    val isRetryable = when (exceptionCause) {
        is AuthenticationException -> exceptionCause.isNetworkError
        else -> false
    }

    val map = mutableMapOf<String, Any>("_isRetryable" to isRetryable)
    if (exceptionCause != null) {
        map["cause"] = exceptionCause.toString()
        map["causeStackTrace"] = exceptionCause.stackTraceToString()
    }
    return map
}
