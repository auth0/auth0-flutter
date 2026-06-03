package com.auth0.auth0_flutter.request_handlers.api

import android.app.Activity
import android.content.Context
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
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
        // Reaching this overload means the call was dispatched without the
        // activity context passkey UI requires. Surface it through the same
        // AuthenticationException shape used elsewhere so `details` is populated.
        val exception = AuthenticationException(
            "a0.passkey.invalid_request",
            "Passkey operations require activity context"
        )
        result.error(exception.getCode(), exception.getDescription(), exception.toMap())
    }
}
