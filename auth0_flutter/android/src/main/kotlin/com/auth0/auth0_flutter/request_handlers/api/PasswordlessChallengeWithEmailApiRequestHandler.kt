package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.PasswordlessChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSWORDLESS_CHALLENGE_WITH_EMAIL_METHOD =
    "auth#passwordlessChallengeWithEmail"

class PasswordlessChallengeWithEmailApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_PASSWORDLESS_CHALLENGE_WITH_EMAIL_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        assertHasProperties(listOf("email", "connection"), args)

        val email = args["email"] as? String
            ?: return result.error("INVALID_ARGUMENT", "'email' must be a String.", null)
        val connection = args["connection"] as? String
            ?: return result.error("INVALID_ARGUMENT", "'connection' must be a String.", null)
        val allowSignup = args["allowSignup"] as? Boolean ?: false

        api.passwordlessClient()
            .challengeWithEmail(email, connection, allowSignup)
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
