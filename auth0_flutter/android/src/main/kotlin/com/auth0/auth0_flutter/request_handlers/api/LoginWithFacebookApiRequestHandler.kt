package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_LOGIN_WITH_FACEBOOK_METHOD = "auth#loginWithFacebook"

class LoginWithFacebookApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_LOGIN_WITH_FACEBOOK_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        assertHasProperties(listOf("accessToken"), request.data)

        val accessToken = request.data["accessToken"] as String
        val builder = api.loginWithNativeSocialToken(accessToken, "facebook")

        // Add optional parameters
        (request.data["scopes"] as? List<*>)?.let { scopes ->
            builder.setScope((scopes as List<String>).joinToString(" "))
        }
        (request.data["audience"] as? String)?.let { builder.setAudience(it) }

        if (request.data["parameters"] is HashMap<*, *>) {
            builder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        builder.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                result.success(credentials.toMap())
            }
        })
    }
}
