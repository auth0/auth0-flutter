package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.my_account.MyAccountRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterMyAccountMethodCallHandler(
    private val myAccountRequestHandlers: List<MyAccountRequestHandler>
) : MethodCallHandler {
    lateinit var context: Context

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)

        val handler = myAccountRequestHandlers.find { it.method == call.method }
        if (handler != null) {
            val accessToken = request.data["accessToken"] as? String ?: ""
            val client = MyAccountAPIClient(request.account, accessToken)

            handler.handle(client, request, result)
        } else {
            result.notImplemented()
        }
    }
}
