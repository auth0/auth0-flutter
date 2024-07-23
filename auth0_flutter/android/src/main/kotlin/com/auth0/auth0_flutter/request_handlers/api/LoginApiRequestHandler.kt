package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

private const val AUTH_LOGIN_METHOD = "auth#login"

class LoginApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_LOGIN_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data

        assertHasProperties(listOf("usernameOrEmail", "password", "connectionOrRealm"), args)

        val loginBuilder = api
            .login(
                args["usernameOrEmail"] as String,
                args["password"] as String,
                args["connectionOrRealm"] as String
            )

        val scopes = (args["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        loginBuilder.setScope(scopes.joinToString(separator = " "))

        if (args["audience"] is String) {
            loginBuilder.setAudience(args["audience"] as String)
        }

        if (args["parameters"] is HashMap<*, *>) {
            loginBuilder.addParameters(args["parameters"] as Map<String, String>)
        }

        loginBuilder.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                val scope = credentials.scope?.split(" ") ?: listOf()
                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
                sdf.setTimeZone(TimeZone.getTimeZone("UTC"))

                val formattedDate = sdf.format(credentials.expiresAt)
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
