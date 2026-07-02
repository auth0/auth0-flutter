package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.android.result.PasswordlessChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSWORDLESS_LOGIN_WITH_OTP_METHOD =
    "auth#passwordlessLoginWithOtp"

class PasswordlessLoginWithOtpApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_PASSWORDLESS_LOGIN_WITH_OTP_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        assertHasProperties(listOf("authSession", "otp"), args)

        val authSession = args["authSession"] as String
        val otp = args["otp"] as String

        val loginBuilder = api.passwordlessClient()
            .loginWithOTP(PasswordlessChallenge(authSession), otp)

        val scopes = (args["scopes"] as? ArrayList<*>) ?: arrayListOf<String>()
        if (scopes.isNotEmpty()) {
            loginBuilder.setScope(scopes.joinToString(separator = " "))
        }

        if (args["audience"] is String) {
            loginBuilder.setAudience(args["audience"] as String)
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
