package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.mfa.MfaRequestHandler
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterMfaMethodCallHandler(
    private val mfaRequestHandlers: List<MfaRequestHandler>
) : MethodCallHandler {

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)

        val handler = mfaRequestHandlers.find { it.method == call.method }
        if (handler != null) {
            assertHasProperties(listOf("mfaToken"), request.data)
            val mfaToken = request.data["mfaToken"] as String
            val client = AuthenticationAPIClient(request.account).mfaClient(mfaToken)

            handler.handle(client, request, result)
        } else {
            result.notImplemented()
        }
    }
}
