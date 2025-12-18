package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.UserProfile
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_USERINFO_METHOD = "auth#userInfo"

class UserInfoApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_USERINFO_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("accessToken"), request.data)

        val accessToken = request.data["accessToken"] as String
        val tokenType = request.data["tokenType"] as? String ?: "Bearer"
        val builder = api.userInfo(accessToken, tokenType)

        if (request.data["parameters"] is HashMap<*, *>) {
            builder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        builder
            .start(object : Callback<UserProfile, AuthenticationException> {
                override fun onFailure(exception: AuthenticationException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
                    )
                }

                override fun onSuccess(res: UserProfile) {
                    result.success(res.toMap())
                }
            })
    }
}
