package com.auth0.auth0_flutter

import com.auth0.android.myaccount.MyAccountException

fun MyAccountException.toMyAccountMap(): Map<String, Any> {
    val exception = this
    return buildMap {
        put("_statusCode", exception.statusCode)
        put("_errorFlags", mapOf(
            "isNetworkError" to exception.isNetworkError,
        ))
    }
}
