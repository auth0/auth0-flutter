package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.callback.Callback
import com.auth0.android.jwt.JWT
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.createUserProfileFromClaims
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
import java.security.InvalidParameterException
import java.text.SimpleDateFormat
import java.util.*

class GetCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getCredentials";

    override fun handle(
        credentialsManager: CredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        var scope: String? = null;
        var minTtl: Int? = null;
        var parameters: Map<String, String>? = null;

        val scopes = request.data.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ");
        }

        if (request.data.getOrDefault("minTtl", null) is Int) {
            minTtl = request.data["minTtl"] as Int;
        }

        if (request.data.getOrDefault("parameters", null) is HashMap<*, *>) {
            parameters = request.data["parameters"] as Map<String, String>;
        }

        getCredentials(credentialsManager, scope, minTtl, parameters, object:
            Callback<Credentials, CredentialsManagerException> {
            override fun onFailure(exception: CredentialsManagerException) {
                result.error(exception.message ?: "UNKNOWN ERROR", exception.message, exception);
            }

            override fun onSuccess(credentials: Credentials) {
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val jwt = JWT(credentials.idToken)
                val userProfile = createUserProfileFromClaims(jwt.claims)
                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)

                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to userProfile.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scopes,
                        "type" to credentials.type
                    )
                )
            }
        });
    }

    private fun getCredentials(credentialsManager: CredentialsManager, scope: String?, minTtl: Int?, parameters: Map<String, String>?, callback: Callback<Credentials, CredentialsManagerException>) {
        if (scope == null && minTtl == null && parameters == null) {
            credentialsManager.getCredentials(callback);
        } else if (minTtl != null && parameters == null) {
            credentialsManager.getCredentials(scope, minTtl, callback);
        } else if (minTtl != null && parameters != null) {
            credentialsManager.getCredentials(scope, minTtl, parameters, callback);
        } else {
            throw IllegalArgumentException("Can't specify 'scopes' or 'parameters' without specifying 'minTtl'.");
        }
    }
}
