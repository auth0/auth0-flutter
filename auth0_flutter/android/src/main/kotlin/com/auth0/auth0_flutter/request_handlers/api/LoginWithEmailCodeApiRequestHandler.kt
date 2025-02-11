package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap

private const val EMAIL_LOGIN_METHOD = "auth#loginWithEmail"

class LoginWithEmailCodeApiRequestHandler : ApiRequestHandler {
    override val method: String = EMAIL_LOGIN_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        assertHasProperties(listOf("email", "verificationCode"), args)

        val builder = api.loginWithEmail(
            args["email"] as String,
            args["verificationCode"] as String
        ).apply {
            val scopes = (args["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
            setScope(scopes.joinToString(separator = " "))
            if (args["audience"] is String) {
                setAudience(args["audience"] as String)
            }
            if (args["parameters"] is HashMap<*, *>) {
                addParameters(args["parameters"] as Map<String, String>)
            }
        }

        builder.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(error: AuthenticationException) {
                result.error(
                    error.getCode(),
                    error.getDescription(),
                    error.toMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                val scope = credentials.scope?.split(" ") ?: listOf()
                val formattedDate = credentials.expiresAt.toInstant().toString()
                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to credentials.user.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scope,
                        "tokenType" to credentials.type
                    )
                )
            }
        })
    }
}
