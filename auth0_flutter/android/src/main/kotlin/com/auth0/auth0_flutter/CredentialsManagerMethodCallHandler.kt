package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.authentication.storage.SharedPreferencesStorage
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class CredentialsManagerMethodCallHandler(private val requestHandlers: List<CredentialsManagerRequestHandler>) : MethodCallHandler {
    lateinit var context: Context

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        var requestHandler = requestHandlers.find { it.method == call.method };

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call);

            val api = AuthenticationAPIClient(request.account);
            val storage = SharedPreferencesStorage(context);
            val credentialsManager = SecureCredentialsManager(context, api, storage);
            val useLocalAuthentication = request.data["useLocalAuthentication"] as Boolean? ?: false;
            if (useLocalAuthentication) {
                credentialsManager.requireAuthentication(context as Activity, 111, null, null)
            }
            requestHandler.handle(credentialsManager, context, request, result);
        } else {
            result.notImplemented()
        }
    }
}
