package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import com.auth0.auth0_flutter_.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterWebAuthMethodCallHandler : MethodCallHandler {
    lateinit var context: Context

    private var requestHandlers = setOf(
        LoginWebAuthRequestHandler(),
        LogoutWebAuthRequestHandler()
    );

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        var requestHandler = requestHandlers.find { it.method == call.method };

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call);

            requestHandler.handle(context, request, result);
        } else {
            result.notImplemented()
        }
    }
}
