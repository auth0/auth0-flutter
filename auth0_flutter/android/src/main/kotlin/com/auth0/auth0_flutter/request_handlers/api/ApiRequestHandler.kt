package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

interface ApiRequestHandler {
    val method: String
    fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result)
}

