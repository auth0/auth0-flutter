package com.auth0.auth0_flutter

import com.auth0.android.myaccount.MyAccountException

fun MyAccountException.toMyAccountMap(): Map<String, Any> {
    val exception = this
    return buildMap {
        put("_statusCode", exception.statusCode)
        put("_title", exception.getCode())
        put("_detail", exception.getDescription())
        put("_errorFlags", mapOf(
            "isNetworkError" to exception.isNetworkError,
        ))
        exception.validationErrors?.let { errors ->
            put("validation_errors", errors.map {
                mapOf(
                    "detail" to it.detail,
                    "field" to it.field,
                    "pointer" to it.pointer,
                    "source" to it.source
                )
            })
        }
    }
}
