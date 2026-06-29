package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

interface MfaRequestHandler {
    val method: String
    fun handle(client: MfaApiClient, request: MethodCallRequest, result: MethodChannel.Result)
}
