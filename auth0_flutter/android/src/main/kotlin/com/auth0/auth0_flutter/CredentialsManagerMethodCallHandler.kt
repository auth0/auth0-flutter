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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val requestHandler = requestHandlers.find { it.method == call.method }

        if (requestHandler != null) {
            val request = MethodCallRequest.fromCall(call)
            val activity = this.activity

            val configuration = request.data["credentialsManagerConfiguration"] as Map<*, *>?

            val sharedPreferenceConfiguration = configuration?.get("android")
            val sharedPreferenceName: String? = if (sharedPreferenceConfiguration != null) {
                (sharedPreferenceConfiguration as Map<String, String>)["sharedPreferencesName"]
            } else null

            val storage = sharedPreferenceName?.let {
                SharedPreferencesStorage(context, it)
            } ?: SharedPreferencesStorage(context)

            val localAuthentication = request.data["localAuthentication"] as Map<String, Any>?
            val useDPoP = request.data["useDPoP"] as? Boolean ?: false

            val credentialsManagerInstance: SecureCredentialsManager

            if (useDPoP) {
                // Create an AuthenticationAPIClient with DPoP enabled
                val apiClient = AuthenticationAPIClient(request.account).useDPoP(context)
                
                if (localAuthentication != null) {
                    if (activity !is FragmentActivity) {
                        result.error(
                            "FragmentActivity required",
                            "The Activity is not a FragmentActivity, which is required for biometric authentication.",
                            null
                        )
                        return
                    }

                    val builder = LocalAuthenticationOptions.Builder()
                    (localAuthentication["title"] as String?)?.let { builder.setTitle(it) }
                    (localAuthentication["description"] as String?)?.let { builder.setDescription(it) }
                    (localAuthentication["cancelTitle"] as String?)?.let { builder.setNegativeButtonText(it) }

                    val authenticationLevel = localAuthentication["authenticationLevel"] as Int?
                    if (authenticationLevel != null) {
                        when (authenticationLevel) {
                            0 -> builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
                            1 -> builder.setAuthenticationLevel(AuthenticationLevel.WEAK)
                            2 -> builder.setAuthenticationLevel(AuthenticationLevel.DEVICE_CREDENTIAL)
                        }
                    } else {
                        builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
                    }
                    builder.setDeviceCredentialFallback(true)

                    credentialsManagerInstance = SecureCredentialsManager(
                        apiClient, context, request.account, storage, activity, builder.build()
                    )
                } else {
                    credentialsManagerInstance = SecureCredentialsManager(
                        apiClient, context, request.account, storage
                    )
                }
            } else {
                // Use default constructors when DPoP is not enabled
                if (localAuthentication != null) {
                    if (activity !is FragmentActivity) {
                        result.error(
                            "FragmentActivity required",
                            "The Activity is not a FragmentActivity, which is required for biometric authentication.",
                            null
                        )
                        return
                    }

                    val builder = LocalAuthenticationOptions.Builder()
                    (localAuthentication["title"] as String?)?.let { builder.setTitle(it) }
                    (localAuthentication["description"] as String?)?.let { builder.setDescription(it) }
                    (localAuthentication["cancelTitle"] as String?)?.let { builder.setNegativeButtonText(it) }

                    val authenticationLevel = localAuthentication["authenticationLevel"] as Int?
                    if (authenticationLevel != null) {
                        when (authenticationLevel) {
                            0 -> builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
                            1 -> builder.setAuthenticationLevel(AuthenticationLevel.WEAK)
                            2 -> builder.setAuthenticationLevel(AuthenticationLevel.DEVICE_CREDENTIAL)
                        }
                    } else {
                        builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
                    }
                    builder.setDeviceCredentialFallback(true)

                    credentialsManagerInstance = SecureCredentialsManager(
                        context, request.account, storage, activity, builder.build()
                    )
                } else {
                    credentialsManagerInstance = SecureCredentialsManager(
                        context, request.account, storage
                    )
                }
            }

            requestHandler.handle(credentialsManagerInstance, context, request, result)
        } else {
            result.notImplemented()
        }
    }
}