package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.api.ApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class Auth0FlutterAuthMethodCallHandler(
    private val apiRequestHandlers: List<ApiRequestHandler>
) : MethodCallHandler {
    lateinit var context: Context
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)
        
        val apiHandler = apiRequestHandlers.find { it.method == call.method }
        if (apiHandler != null) {
            val api = AuthenticationAPIClient(request.account)
            
            val useDPoP = request.data["useDPoP"] as? Boolean ?: false
            if (useDPoP) {
                api.useDPoP(context)
            }

            apiHandler.handle(api, request, result)
        } else {
            result.notImplemented()
        }
    }
}
