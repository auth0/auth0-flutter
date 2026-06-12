package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.UserData
import com.auth0.android.result.PasskeyRegistrationChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSKEY_SIGNUP_CHALLENGE_METHOD = "auth#passkeySignupChallenge"

class PasskeySignupChallengeApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_PASSKEY_SIGNUP_CHALLENGE_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        val connection = args["connection"] as? String
        val organization = args["organization"] as? String

        val userMetadata = (args["userMetadata"] as? Map<*, *>)
            ?.mapKeys { it.key.toString() }
            ?.mapValues { it.value.toString() }
        val userData = UserData(
            email = args["email"] as? String,
            phoneNumber = args["phoneNumber"] as? String,
            userName = args["username"] as? String,
            name = args["name"] as? String,
            givenName = args["givenName"] as? String,
            familyName = args["familyName"] as? String,
            nickName = args["nickname"] as? String,
            picture = args["picture"] as? String,
            userMetadata = userMetadata
        )

        api.signupWithPasskey(userData, connection, organization)
            .start(object : Callback<PasskeyRegistrationChallenge, AuthenticationException> {
                override fun onFailure(exception: AuthenticationException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
                    )
                }

                override fun onSuccess(challenge: PasskeyRegistrationChallenge) {
                    // Forward the full WebAuthn registration options so the
                    // create-credential step can pass them to Credential
                    // Manager's CreatePublicKeyCredentialRequest verbatim.
                    val authParamsPublicKey: Map<*, *> = Gson().fromJson(
                        Gson().toJson(challenge.authParamsPublicKey),
                        Map::class.java
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
