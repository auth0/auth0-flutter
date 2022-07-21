package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.DatabaseUser
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_SIGNUP_METHOD = "auth#signUp"

class SignupApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_SIGNUP_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        assertHasProperties(listOf("email", "password", "connection"), request.data)

        val builder = api.createUser(
                email = request.data["email"] as String,
                password = request.data["password"] as String,
                username = request.data["username"] as String?,
                connection = request.data["connection"] as String,
                userMetadata = request.data["userMetadata"] as Map<String, String>?
            )

        if (request.data.getOrDefault("parameters", null) is HashMap<*, *>) {
            builder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        builder.start(object : Callback<DatabaseUser, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(user: DatabaseUser) {
                result.success(
                    mapOf(
                        "emailVerified" to user.isEmailVerified,
                        "email" to user.email,
                        "username" to user.username
                    )
                )
            }
        })
    }
}
