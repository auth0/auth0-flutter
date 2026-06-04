package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.APICredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel

class GetApiCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getApiCredentials"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val audience = request.data["audience"] as String?
        if (audience == null) {
            result.error("UNKNOWN ERROR", "audience is required to get API credentials", null)
            return
        }

        var scope: String? = null
        val scopes = (request.data["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ")
        }

        val minTtl = request.data["minTtl"] as Int? ?: 0
        val parameters = request.data["parameters"] as Map<String, String>? ?: mapOf()
        val headers = request.data["headers"] as Map<String, String>? ?: mapOf()

        credentialsManager.getApiCredentials(
            audience, scope, minTtl, parameters, headers,
            object : Callback<APICredentials, CredentialsManagerException> {
                override fun onFailure(exception: CredentialsManagerException) {
                    result.error(exception.message ?: "UNKNOWN ERROR", exception.message, exception.toMap())
                }

                override fun onSuccess(credentials: APICredentials) {
                    val grantedScopes = credentials.scope.split(" ").filter { it.isNotEmpty() }
                    val formattedDate = credentials.expiresAt.toInstant().toString()
                    result.success(
                        mapOf(
                            "accessToken" to credentials.accessToken,
                            "tokenType" to credentials.type,
                            "expiresAt" to formattedDate,
                            "scopes" to grantedScopes
                        )
                    )
                }
            }
        )
    }
}
