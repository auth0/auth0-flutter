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

/**
 * Constants for mapping biometric authentication levels between Dart and Kotlin.
 * These values must match the BiometricAuthenticationLevel enum in lib/src/credentials_manager.dart
 */
private object BiometricAuthLevel {
    const val STRONG = 0
    const val WEAK = 1
    const val DEVICE_CREDENTIAL = 2
}

class CredentialsManagerMethodCallHandler(private val requestHandlers: List<CredentialsManagerRequestHandler>) : MethodCallHandler {
    lateinit var activity: Activity
    lateinit var context: Context

    // Cache key components to determine if we need to recreate the manager
    private data class ManagerCacheKey(
        val accountDomain: String,
        val accountClientId: String,
        val sharedPreferenceName: String?,
        val useDPoP: Boolean,
        val hasLocalAuth: Boolean
    )

    private var cachedManager: SecureCredentialsManager? = null
    private var cachedKey: ManagerCacheKey? = null

    private fun buildLocalAuthenticationOptions(localAuthentication: Map<String, Any>): LocalAuthenticationOptions {
        val builder = LocalAuthenticationOptions.Builder()
        (localAuthentication["title"] as String?)?.let { builder.setTitle(it) }
        (localAuthentication["description"] as String?)?.let { builder.setDescription(it) }
        (localAuthentication["cancelTitle"] as String?)?.let { builder.setNegativeButtonText(it) }

        val authenticationLevel = localAuthentication["authenticationLevel"] as Int?
        when (authenticationLevel) {
            BiometricAuthLevel.STRONG -> builder.setAuthenticationLevel(AuthenticationLevel.STRONG)
            BiometricAuthLevel.WEAK -> builder.setAuthenticationLevel(AuthenticationLevel.WEAK)
            BiometricAuthLevel.DEVICE_CREDENTIAL -> builder.setAuthenticationLevel(AuthenticationLevel.DEVICE_CREDENTIAL)
            else -> builder.setAuthenticationLevel(AuthenticationLevel.STRONG) // Default to STRONG
        }
        builder.setDeviceCredentialFallback(true)
        
        return builder.build()
    }

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

            // Create cache key to determine if we can reuse existing manager
            val currentKey = ManagerCacheKey(
                accountDomain = request.account.domain,
                accountClientId = request.account.clientId,
                sharedPreferenceName = sharedPreferenceName,
                useDPoP = useDPoP,
                hasLocalAuth = localAuthentication != null
            )

            // Reuse cached manager if configuration hasn't changed
            val credentialsManagerInstance: SecureCredentialsManager = if (cachedKey == currentKey && cachedManager != null) {
                cachedManager!!
            } else {
                // Configuration changed or no cached manager - create new one
                
                // Validate activity type early if biometric auth is required
                if (localAuthentication != null && activity !is FragmentActivity) {
                    result.error(
                        "credentialsManager#fragment-activity-required",
                        "The Activity must extend FlutterFragmentActivity (not FlutterActivity) for biometric authentication. " +
                        "Update your MainActivity.kt to extend FlutterFragmentActivity. " +
                        "See: https://developer.android.com/reference/androidx/fragment/app/FragmentActivity",
                        null
                    )
                    return
                }

                // Build local authentication options if needed
                val options = localAuthentication?.let { buildLocalAuthenticationOptions(it) }

                // Create API client and enable DPoP if requested
                val apiClient = AuthenticationAPIClient(request.account)
                if (useDPoP) {
                    apiClient.useDPoP(context)
                }

                // Create the credentials manager with appropriate constructor
                val newManager = if (options != null) {
                    SecureCredentialsManager(
                        apiClient, context, request.account, storage, activity as FragmentActivity, options
                    )
                } else {
                    SecureCredentialsManager(
                        apiClient, context, request.account, storage
                    )
                }

                // Cache the new manager
                cachedManager = newManager
                cachedKey = currentKey
                newManager
            }

            requestHandler.handle(credentialsManagerInstance, context, request, result)
        } else {
            result.notImplemented()
        }
    }
}