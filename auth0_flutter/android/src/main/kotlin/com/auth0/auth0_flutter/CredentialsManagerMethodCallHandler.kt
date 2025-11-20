package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.storage.AuthenticationLevel
import com.auth0.android.authentication.storage.LocalAuthenticationOptions
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.authentication.storage.SharedPreferencesStorage
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class CredentialsManagerMethodCallHandler(private val requestHandlers: List<CredentialsManagerRequestHandler>) : MethodCallHandler {
    lateinit var activity: Activity
    lateinit var context: Context

    private var credentialsManagerInstance: SecureCredentialsManager? = null

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val requestHandler = requestHandlers.find { it.method == call.method }

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call)
            val activity = this.activity

            if (credentialsManagerInstance == null) {
                val configuration = request.data["credentialsManagerConfiguration"] as Map<*, *>?

                val sharedPreferenceConfiguration = configuration?.get("android")
                val sharedPreferenceName: String? = if (sharedPreferenceConfiguration != null) {
                    (sharedPreferenceConfiguration as Map<String, String>)["sharedPreferencesName"]
                } else null

                val storage = sharedPreferenceName?.let {
                    SharedPreferencesStorage(context, it)
                } ?: SharedPreferencesStorage(context)

                val localAuthentication = request.data["localAuthentication"] as Map<String, String>?

                if (localAuthentication != null) {
                    if (activity !is FragmentActivity) {
                        result.error(
                            "credentialsManager#biometric-error",
                            "The Activity is not a FragmentActivity, which is required for biometric authentication.",
                            null
                        )
                        return
                    }

                    val builder = LocalAuthenticationOptions.Builder()
                    localAuthentication["title"]?.let { builder.setTitle(it) }
                    localAuthentication["description"]?.let { builder.setDescription(it) }
                    localAuthentication["cancelTitle"]?.let { builder.setNegativeButtonText(it) }

                    builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
                    builder.setDeviceCredentialFallback(true)

                    credentialsManagerInstance = SecureCredentialsManager(context, request.account, storage, activity, builder.build())
                } else {
                    credentialsManagerInstance = SecureCredentialsManager(context, request.account, storage)
                }
            }

            requestHandler.handle(credentialsManagerInstance!!, context, request, result)
        } else {
            result.notImplemented()
        }
    }
}