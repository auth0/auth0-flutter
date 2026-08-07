package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.mfa.MfaException.MfaChallengeException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Challenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_MULTIFACTORCHALLENGE_METHOD = "auth#multifactorChallenge"

class MultifactorChallengeApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_MULTIFACTORCHALLENGE_METHOD

    override fun handle(
            api: AuthenticationAPIClient,
            request: MethodCallRequest,
            result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("mfaToken", "authenticatorId"), request.data)

        val builder = api
                .mfaClient(request.data["mfaToken"] as String)
                .challenge(request.data["authenticatorId"] as String)

        builder.start(object : Callback<Challenge, MfaChallengeException> {
            override fun onFailure(exception: MfaChallengeException) {
                result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMfaMap()
                )
            }

            override fun onSuccess(challenge: Challenge) {
                result.success(
                    mapOf(
                        "challengeType" to challenge.challengeType,
                        "oobCode" to challenge.oobCode,
                        "bindingMethod" to challenge.bindingMethod
                    )
                )
            }
        })
    }
}
