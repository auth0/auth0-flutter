package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.passwordless.DeliveryMethod
import com.auth0.android.callback.Callback
import com.auth0.android.result.PasswordlessChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSWORDLESS_CHALLENGE_WITH_PHONE_NUMBER_METHOD =
    "auth#passwordlessChallengeWithPhoneNumber"

class PasswordlessChallengeWithPhoneNumberApiRequestHandler : ApiRequestHandler {
    override val method: String =
        AUTH_PASSWORDLESS_CHALLENGE_WITH_PHONE_NUMBER_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        assertHasProperties(listOf("phoneNumber", "connection"), args)

        val phoneNumber = args["phoneNumber"] as? String
            ?: return result.error("INVALID_ARGUMENT", "'phoneNumber' must be a String.", null)
        val connection = args["connection"] as? String
            ?: return result.error("INVALID_ARGUMENT", "'connection' must be a String.", null)
        val allowSignup = args["allowSignup"] as? Boolean ?: false
        val deliveryMethod =
            if (args["deliveryMethod"] == "voice") DeliveryMethod.VOICE
            else DeliveryMethod.TEXT

        api.passwordlessClient()
            .challengeWithPhoneNumber(phoneNumber, connection, deliveryMethod, allowSignup)
            .start(object : Callback<PasswordlessChallenge, AuthenticationException> {
                override fun onFailure(exception: AuthenticationException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
                    )
                }

                override fun onSuccess(challenge: PasswordlessChallenge) {
                    result.success(mapOf("authSession" to challenge.authSession))
                }
            })
    }
}
