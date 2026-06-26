package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.PasskeyChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSKEY_LOGIN_CHALLENGE_METHOD = "auth#passkeyLoginChallenge"

class PasskeyLoginChallengeApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_PASSKEY_LOGIN_CHALLENGE_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        val connection = args["connection"] as? String
        val organization = args["organization"] as? String

        api.passkeyChallenge(connection, organization)
            .start(object : Callback<PasskeyChallenge, AuthenticationException> {
                override fun onFailure(exception: AuthenticationException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
                    )
                }

                override fun onSuccess(challenge: PasskeyChallenge) {
                    val authParamsPublicKey = mapOf(
                        "challenge" to challenge.authParamsPublicKey.challenge,
                        "rpId" to challenge.authParamsPublicKey.rpId,
                        "timeout" to challenge.authParamsPublicKey.timeout,
                        "userVerification" to challenge.authParamsPublicKey.userVerification
                    )
                    result.success(
                        mapOf(
                            "authSession" to challenge.authSession,
                            "authParamsPublicKey" to authParamsPublicKey
                        )
                    )
                }
            })
    }
}
