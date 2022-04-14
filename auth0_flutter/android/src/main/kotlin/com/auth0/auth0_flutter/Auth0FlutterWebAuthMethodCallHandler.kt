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

internal const val WEBAUTH_LOGIN_METHOD = "webAuth#login"
internal const val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"

class Auth0FlutterWebAuthMethodCallHandler : MethodCallHandler {
    lateinit var context: Context

    // This is mainly used by tests to be able to run assertions on the
    // handler actually being used to handle the request.
    var resolvedHandler: WebAuthRequestHandler? = null

    var handlerResolver = { call: MethodCall, request: MethodCallRequest ->
        when(call.method) {
            WEBAUTH_LOGIN_METHOD -> LoginWebAuthRequestHandler(WebAuthProvider.login(request.account))
            WEBAUTH_LOGOUT_METHOD -> LogoutWebAuthRequestHandler(WebAuthProvider.logout(request.account))
            else -> null
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)
        val requestHandler = handlerResolver(call, request)

        if (requestHandler != null) {
            resolvedHandler = requestHandler
            requestHandler.handle(context, request, result)
        } else {
            result.notImplemented()
        }
    }
}
