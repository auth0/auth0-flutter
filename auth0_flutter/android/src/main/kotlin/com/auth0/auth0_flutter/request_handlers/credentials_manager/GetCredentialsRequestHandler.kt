package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
import java.util.*

class GetCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getCredentials"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        var scope: String? = null

        val scopes = (request.data["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ")
        }

        val minTtl = request.data.get("minTtl") as Int? ?: 0
        val parameters = request.data.get("parameters") as Map<String, String>? ?: mapOf()
        val forceRefresh = request.data.get("forceRefresh") as Boolean? ?: false

        credentialsManager.getCredentials(scope, minTtl, parameters, forceRefresh, object :
            Callback<Credentials, CredentialsManagerException> {
            override fun onFailure(exception: CredentialsManagerException) {
                result.error(exception.message ?: "UNKNOWN ERROR", exception.message, exception)
            }

            override fun onSuccess(credentials: Credentials) {
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val formattedDate = credentials.expiresAt.toInstant().toString()
                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to credentials.user.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scopes,
                        "tokenType" to credentials.type
                    )
                )
            }
        })
    }
}
