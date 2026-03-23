package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.storage.CredentialsManagerException

fun CredentialsManagerException.toMap(): Map<String, Any> {
    val isRetryable = when (val exceptionCause = this.cause) {
        is AuthenticationException -> exceptionCause.isNetworkError
        else -> false
    }

    return mapOf("_isRetryable" to isRetryable)
}
