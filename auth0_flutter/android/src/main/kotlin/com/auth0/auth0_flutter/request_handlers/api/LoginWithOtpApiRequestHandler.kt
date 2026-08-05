package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.mfa.MfaException.MfaVerifyException
import com.auth0.android.authentication.mfa.MfaVerificationType
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.toMfaMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel
import java.util.*

private const val AUTH_LOGIN_OTP_METHOD = "auth#loginOtp"

class LoginWithOtpApiRequestHandler: ApiRequestHandler {
    override val method: String = AUTH_LOGIN_OTP_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data

        assertHasProperties(listOf("mfaToken", "otp"), args)

        // v4 removed AuthenticationAPIClient.loginWithOTP; the inline MFA OTP
        // flow now goes through the dedicated MfaApiClient.
        val loginBuilder = api
            .mfaClient(args["mfaToken"] as String)
            .verify(MfaVerificationType.Otp(args["otp"] as String))

        loginBuilder.start(object : Callback<Credentials, MfaVerifyException> {
            override fun onFailure(exception: MfaVerifyException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMfaMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                val scope = credentials.scope?.split(" ") ?: listOf()
                var formattedDate = credentials.expiresAt.toInstant().toString()
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
