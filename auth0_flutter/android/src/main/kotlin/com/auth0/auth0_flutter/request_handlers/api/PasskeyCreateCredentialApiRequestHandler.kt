package com.auth0.auth0_flutter.request_handlers.api

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.CancellationSignal
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.GetCredentialUnsupportedException
import androidx.credentials.exceptions.NoCredentialException
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

private const val AUTH_PASSKEY_CREATE_CREDENTIAL_METHOD = "auth#passkeyCreateCredential"

/**
 * Presents the platform passkey UI for an existing login challenge and returns
 * the resulting WebAuthn assertion as a credential map. This handler does not
 * contact Auth0; the returned credential is passed back to
 * [PasskeyLoginApiRequestHandler] to exchange for tokens.
 */
class PasskeyCreateCredentialApiRequestHandler : PasskeyApiRequestHandler {
    override val method: String = AUTH_PASSKEY_CREATE_CREDENTIAL_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result,
        context: Context,
        activity: Activity?
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error(
                "PASSKEY_ERROR",
                "Passkey authentication requires Android 9 or higher",
                null
            )
            return
        }

        val args = request.data
        val challengeMap = args["challenge"] as? Map<*, *>
        if (challengeMap == null) {
            result.error("PASSKEY_ERROR", "Missing challenge argument", null)
            return
        }

        val authParamsPublicKey = challengeMap["authParamsPublicKey"] as? Map<*, *>
        if (authParamsPublicKey == null) {
            result.error("PASSKEY_ERROR", "Missing authParamsPublicKey in challenge", null)
            return
        }

        // Credential Manager must be invoked with an Activity-based context to
        // launch its selector UI; the application context cannot present UI.
        if (activity == null) {
            result.error(
                "PASSKEY_ERROR",
                "Passkey authentication requires an Activity context, but none was available.",
                null
            )
            return
        }

        val publicKeyJson = Gson().toJson(authParamsPublicKey)
        val credentialOption = GetPublicKeyCredentialOption(publicKeyJson)
        val getCredRequest = GetCredentialRequest(listOf(credentialOption))

        val credentialManager = CredentialManager.create(context)
        val executor = Executors.newSingleThreadExecutor()

        credentialManager.getCredentialAsync(
            activity,
            getCredRequest,
            CancellationSignal(),
            executor,
            object :
                androidx.credentials.CredentialManagerCallback<GetCredentialResponse, GetCredentialException> {
                override fun onError(e: GetCredentialException) {
                    val exception = handleGetCredentialFailure(e)
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMap()
                    )
                }

                override fun onResult(credentialResponse: GetCredentialResponse) {
                    when (val credential = credentialResponse.credential) {
                        is PublicKeyCredential -> {
                            // authenticationResponseJson already follows the
                            // standard WebAuthn JSON format expected by the
                            // login step.
                            val credentialMap: Map<*, *> = Gson().fromJson(
                                credential.authenticationResponseJson,
                                Map::class.java
                            )
                            result.success(credentialMap)
                        }

                        else -> {
                            result.error(
                                "PASSKEY_ERROR",
                                "Received unrecognized credential type ${credential.type}",
                                null
                            )
                        }
                    }
                }
            }
        )
    }

    private fun handleGetCredentialFailure(exception: GetCredentialException): AuthenticationException {
        return when (exception) {
            is GetCredentialCancellationException -> {
                // "a0.authentication_canceled" mirrors the SDK's internal
                // ERROR_VALUE_AUTHENTICATION_CANCELED, which is not public.
                AuthenticationException(
                    "a0.authentication_canceled",
                    "The user cancelled passkey authentication operation."
                )
            }

            is GetCredentialInterruptedException -> {
                AuthenticationException(
                    "a0.passkey.interrupted",
                    "Passkey authentication was interrupted. Please retry the call."
                )
            }

            is GetCredentialUnsupportedException -> {
                AuthenticationException(
                    "a0.passkey.unsupported",
                    "Credential manager is unsupported. Please update the device."
                )
            }

            is NoCredentialException -> {
                AuthenticationException(
                    "a0.passkey.no_credential",
                    "No viable credential is available for the user."
                )
            }

            else -> {
                // Surface the underlying Credential Manager error type and
                // message rather than collapsing to a generic unknown error.
                AuthenticationException(
                    "a0.passkey.${exception.type}",
                    exception.errorMessage?.toString()
                        ?: exception.message
                        ?: "An error occurred when trying to authenticate with passkey."
                )
            }
        }
    }
}
