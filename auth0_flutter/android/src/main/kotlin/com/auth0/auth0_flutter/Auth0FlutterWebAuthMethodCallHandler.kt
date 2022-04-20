package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.WebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterWebAuthMethodCallHandler(private val handlerResolver: (MethodCall, MethodCallRequest) -> WebAuthRequestHandler?) : MethodCallHandler {
    lateinit var context: Context

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)
        val requestHandler = handlerResolver(call, request)

        if (requestHandler != null) {
            requestHandler.handle(context, request, result)
        } else {
            result.notImplemented()
        }
    }
}
