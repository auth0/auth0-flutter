package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.api.*
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class Auth0FlutterAuthMethodCallHandler(private val requestHandlers: List<ApiRequestHandler>) : MethodCallHandler {
    lateinit var context: Context
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val requestHandler = requestHandlers.find { it.method == call.method }

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call)
            val api = AuthenticationAPIClient(request.account)
            
            // Enable DPoP if requested
            val useDPoP = request.data["useDPoP"] as? Boolean ?: false
            if (useDPoP) {
                api.useDPoP(context)
            }

            requestHandler.handle(api, request, result)
        } else {
            result.notImplemented()
        }
    }
}
