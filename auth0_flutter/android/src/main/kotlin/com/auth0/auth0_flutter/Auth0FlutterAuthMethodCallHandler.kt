package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.api.*
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class Auth0FlutterAuthMethodCallHandler(private val requestHandlers: List<ApiRequestHandler>) : MethodCallHandler {
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val requestHandler = requestHandlers.find { it.method == call.method }

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call)
            val api = AuthenticationAPIClient(request.account)

            requestHandler.handle(api, request, result)
        } else {
            result.notImplemented()
        }
    }
}
