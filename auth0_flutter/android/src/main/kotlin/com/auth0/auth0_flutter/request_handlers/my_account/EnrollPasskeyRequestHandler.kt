package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.ClientExtensionResults
import com.auth0.android.request.CredProps
import com.auth0.android.request.PublicKeyCredentials
import com.auth0.android.request.Response
import com.auth0.android.result.AuthnParamsPublicKey
import com.auth0.android.result.PasskeyAuthenticationMethod
import com.auth0.android.result.PasskeyEnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountPasskeyMethodMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_ENROLL_PASSKEY_METHOD =
    "myAccount#enrollPasskey"

class EnrollPasskeyRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_ENROLL_PASSKEY_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(
            listOf(
                "challenge",
                "challenge.authSession",
                "challenge.authenticationMethodId",
                "challenge.authParamsPublicKey",
                "credential",
                "credential.id",
                "credential.rawId",
                "credential.response",
                "credential.response.clientDataJSON",
                "credential.response.attestationObject",
            ),
            request.data
        )

        val challengeMap = request.data["challenge"] as? Map<*, *>
            ?: throw IllegalArgumentException("Required property 'challenge' must be a map.")
        val credentialMap = request.data["credential"] as? Map<*, *>
            ?: throw IllegalArgumentException("Required property 'credential' must be a map.")

        val challenge = reconstructChallenge(challengeMap)
        val credentials = reconstructCredentials(credentialMap)

        client.enroll(credentials, challenge)
            .start(object :
                Callback<PasskeyAuthenticationMethod, MyAccountException> {
                override fun onFailure(
                    exception: MyAccountException
                ) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(
                    res: PasskeyAuthenticationMethod
                ) {
                    result.success(res.toMyAccountPasskeyMethodMap())
                }
            })
    }

    private fun reconstructChallenge(
        challengeMap: Map<*, *>
    ): PasskeyEnrollmentChallenge {
        val gson = Gson()
        // The Flutter layer forwards `authParamsPublicKey` as the verbatim
        // WebAuthn creation options map; convert it back into the SDK's typed
        // representation.
        val authParamsPublicKey = gson.fromJson(
            gson.toJson(challengeMap["authParamsPublicKey"]),
            AuthnParamsPublicKey::class.java
        )
        return PasskeyEnrollmentChallenge(
            challengeMap["authenticationMethodId"] as? String
                ?: throw IllegalArgumentException(
                    "Required property 'challenge.authenticationMethodId' must be a string."),
            challengeMap["authSession"] as? String
                ?: throw IllegalArgumentException(
                    "Required property 'challenge.authSession' must be a string."),
            authParamsPublicKey
        )
    }

    private fun reconstructCredentials(
        credentialMap: Map<*, *>
    ): PublicKeyCredentials {
        val response = credentialMap["response"] as? Map<*, *>
            ?: throw IllegalArgumentException(
                "Required property 'credential.response' must be a map.")
        val clientExtensionResults =
            credentialMap["clientExtensionResults"] as? Map<*, *>
        val credProps = clientExtensionResults?.get("credProps") as? Map<*, *>
        val residentKey = (credProps?.get("rk") as? Boolean) ?: false

        return PublicKeyCredentials(
            authenticatorAttachment =
                (credentialMap["authenticatorAttachment"] as? String)
                    ?: "platform",
            clientExtensionResults = ClientExtensionResults(
                credProps = CredProps(rk = residentKey)
            ),
            id = credentialMap["id"] as? String
                ?: throw IllegalArgumentException(
                    "Required property 'credential.id' must be a string."),
            rawId = credentialMap["rawId"] as? String
                ?: throw IllegalArgumentException(
                    "Required property 'credential.rawId' must be a string."),
            response = Response(
                attestationObject = response["attestationObject"] as? String
                    ?: throw IllegalArgumentException(
                        "Required property 'credential.response.attestationObject' must be a string."),
                authenticatorData = (response["authenticatorData"] as? String) ?: "",
                clientDataJSON = response["clientDataJSON"] as? String
                    ?: throw IllegalArgumentException(
                        "Required property 'credential.response.clientDataJSON' must be a string."),
                transports = (response["transports"] as? List<*>)
                    ?.filterIsInstance<String>() ?: emptyList(),
                signature = (response["signature"] as? String) ?: "",
                userHandle = (response["userHandle"] as? String) ?: ""
            ),
            type = (credentialMap["type"] as? String) ?: "public-key"
        )
    }
}
