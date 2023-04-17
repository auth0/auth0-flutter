package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Challenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
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
        assertHasProperties(listOf("mfaToken"), request.data)

        val challengeTypes = (request.data["types"]) as ArrayList<*>?

        val builder = api.multifactorChallenge(
                mfaToken = request.data["mfaToken"] as String,
                challengeType = challengeTypes?.joinToString(separator = " "),
                authenticatorId = request.data["authenticatorId"] as String?
        )

        builder.start(object : Callback<Challenge, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
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
