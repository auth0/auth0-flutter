package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.authentication.storage.SharedPreferencesStorage
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import com.auth0.auth0_flutter.utils.RequestCodes
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class CredentialsManagerMethodCallHandler(private val requestHandlers: List<CredentialsManagerRequestHandler>) : MethodCallHandler, PluginRegistry.ActivityResultListener {
    lateinit var activity: Activity;

    var credentialsManager: SecureCredentialsManager? = null;

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        var requestHandler = requestHandlers.find { it.method == call.method };

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call);

            val api = AuthenticationAPIClient(request.account);
            val storage = SharedPreferencesStorage(activity);
            credentialsManager = credentialsManager ?: SecureCredentialsManager(activity, api, storage);

            val credentialsManager = credentialsManager as SecureCredentialsManager;

            var localAuthentication = request.data.get("localAuthentication") as Map<String, String>?;

            if (localAuthentication != null) {
                val title = localAuthentication["title"];
                val description = localAuthentication["description"];
                credentialsManager.requireAuthentication(activity, RequestCodes.AUTH_REQ_CODE, title, description);
            }
            requestHandler.handle(credentialsManager, activity, request, result);
        } else {
            result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return credentialsManager?.checkAuthenticationResult(requestCode, resultCode) ?: true;
    }
}
