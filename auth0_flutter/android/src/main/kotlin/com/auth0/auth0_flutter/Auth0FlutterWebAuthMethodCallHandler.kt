package com.auth0.auth0_flutter

import android.app.Activity
import androidx.annotation.NonNull
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.WebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterWebAuthMethodCallHandler(private val requestHandlers: List<WebAuthRequestHandler>) : MethodCallHandler {
    lateinit var activity: Activity

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val requestHandler = requestHandlers.find { it.method == call.method }

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call)

            requestHandler.handle(activity, request, result)
        } else {
            result.notImplemented()
        }
    }
}
