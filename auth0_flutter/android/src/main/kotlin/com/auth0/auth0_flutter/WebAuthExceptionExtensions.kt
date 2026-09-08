package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import io.flutter.plugin.common.MethodChannel

fun AuthenticationException.toWebAuthResult(result: MethodChannel.Result) {
    val details = mutableMapOf<String, Any>("_isRetryable" to isNetworkError)
    cause?.let {
        details["cause"] = it.toString()
        details["causeStackTrace"] = it.stackTraceToString()
    }
    val code = when {
        isCanceled -> "USER_CANCELLED"
        else -> getCode()
    }
    result.error(code, getDescription(), details)
}
