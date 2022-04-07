package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter_.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

private const val AUTH_LOGIN_METHOD = "auth#login"

class LoginApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_LOGIN_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        val args = request.data;
        val authentication = AuthenticationAPIClient(Auth0(args["clientId"] as String, args["domain"] as String));

        authentication
            .login(args["usernameOrEmail"] as String, args["password"] as String, args["connectionOrRealm"] as String)
            .setScope((args["scope"] as List<String>).joinToString(separator = " "))
            .addParameters(args["parameters"] as Map<String, String>)
            .start(object : Callback<Credentials, AuthenticationException> {
                override fun onFailure(exception: AuthenticationException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception
                    );
                }

                override fun onSuccess(credentials: Credentials) {
                    val scope = credentials.scope?.split(" ") ?: listOf()
                    val sdf =
                        SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                    val formattedDate = sdf.format(credentials.expiresAt)
                    result.success(
                        mapOf(
                            "accessToken" to credentials.accessToken,
                            "idToken" to credentials.idToken,
                            "refreshToken" to credentials.refreshToken,
                            "userProfile" to mapOf<String, String>(),
                            "expiresAt" to formattedDate,
                            "scopes" to scope
                        )
                    )
                }
            });
    }
}
