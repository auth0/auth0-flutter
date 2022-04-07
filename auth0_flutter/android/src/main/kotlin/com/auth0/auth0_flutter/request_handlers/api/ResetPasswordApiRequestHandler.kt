package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter_.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

class ResetPasswordApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_RESETPASSWORD_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        result.success("Auth Reset Password Success")
    }
}
