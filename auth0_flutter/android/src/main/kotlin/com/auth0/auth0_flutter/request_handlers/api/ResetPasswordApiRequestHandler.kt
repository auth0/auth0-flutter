package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap

private const val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

class ResetPasswordApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_RESETPASSWORD_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("email", "connection"), request.data)

        val builder = api.resetPassword(
            email = request.data["email"] as String,
            connection = request.data["connection"] as String
        )

        if (request.data.getOrDefault("parameters", null) is HashMap<*, *>) {
            builder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        builder.start(object : Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(res: Void?) {
                result.success(null)
            }
        })
    }
}
