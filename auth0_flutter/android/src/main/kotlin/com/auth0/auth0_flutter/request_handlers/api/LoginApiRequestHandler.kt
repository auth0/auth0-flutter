package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter_.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_LOGIN_METHOD = "auth#login"

class LoginApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_LOGIN_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        result.success("Auth Login Success")
    }
}
