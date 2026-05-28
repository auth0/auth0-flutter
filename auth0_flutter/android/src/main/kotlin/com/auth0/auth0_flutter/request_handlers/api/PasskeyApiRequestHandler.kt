package com.auth0.auth0_flutter.request_handlers.api

import android.app.Activity
import android.content.Context
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

interface PasskeyApiRequestHandler : ApiRequestHandler {
    fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result,
        context: Context,
        activity: Activity?
    )

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        result.error(
            "PASSKEY_ERROR",
            "Passkey operations require activity context",
            null
        )
    }
}
