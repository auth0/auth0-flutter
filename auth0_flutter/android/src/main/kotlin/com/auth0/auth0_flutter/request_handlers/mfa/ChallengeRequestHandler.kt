package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaChallengeException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Challenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaChallengeMap
import com.auth0.auth0_flutter.toMfaMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MFA_CHALLENGE_METHOD = "mfa#challenge"

class ChallengeRequestHandler : MfaRequestHandler {
    override val method: String = MFA_CHALLENGE_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("authenticatorId"), request.data)
        val authenticatorId = request.data["authenticatorId"] as String

        client.challenge(authenticatorId)
            .start(object : Callback<Challenge, MfaChallengeException> {
                override fun onFailure(exception: MfaChallengeException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMfaMap()
                    )
                }

                override fun onSuccess(res: Challenge) {
                    result.success(res.toMfaChallengeMap())
                }
            })
    }
}
