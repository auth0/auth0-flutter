package com.auth0.auth0_flutter_example

import android.app.Activity
import android.os.Build
import android.os.CancellationSignal
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.concurrent.Executors

/**
 * Presents the Android Credential Manager passkey UI and returns a WebAuthn
 * credential to Flutter.
 *
 * This lives in the example app — not the `auth0_flutter` SDK — to demonstrate
 * how an app supplies the passkey credential that the SDK expects:
 * - `getAssertion` authenticates an existing passkey using the `challenge` and
 *   `rpId` from `auth0.api.passkeyLoginChallenge` (for `auth0.api.passkeyLogin`).
 * - `getAttestation` registers a new passkey using the `authParamsPublicKey`
 *   from `auth0.api.passkeySignupChallenge` (for `auth0.api.passkeySignup`).
 */
class PasskeyAuthenticator {

    companion object {
        const val CHANNEL_NAME = "com.auth0.auth0_flutter_example/passkey"
    }

    // The Activity is passed in per-call rather than held as a field, so this
    // authenticator never outlives (and never leaks) the Activity that owns the
    // method channel.
    fun handle(activity: Activity, call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("unsupported", "Passkeys require Android 9 (API 28)+", null)
            return
        }

        when (call.method) {
            "getAssertion" -> getAssertion(activity, call, result)
            "getAttestation" -> getAttestation(activity, call, result)
            else -> result.notImplemented()
        }
    }

    // MARK: Login (assertion)

    private fun getAssertion(
        activity: Activity,
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val challenge = call.argument<String>("challenge")
        val rpId = call.argument<String>("rpId")
        if (challenge == null || rpId == null) {
            result.error("bad_args", "Missing challenge or rpId", null)
            return
        }

        // Build the WebAuthn request JSON expected by Credential Manager.
        val requestJson = JSONObject()
            .put("challenge", challenge)
            .put("rpId", rpId)
            .put("userVerification", "required")
            .toString()

        val option = GetPublicKeyCredentialOption(requestJson)
        val request = GetCredentialRequest(listOf(option))
        val credentialManager = CredentialManager.create(activity)

        credentialManager.getCredentialAsync(
            activity,
            request,
            CancellationSignal(),
            Executors.newSingleThreadExecutor(),
            object : CredentialManagerCallback<GetCredentialResponse, GetCredentialException> {
                override fun onResult(response: GetCredentialResponse) {
                    val credential = response.credential
                    if (credential is PublicKeyCredential) {
                        // authenticationResponseJson is the standard WebAuthn
                        // assertion; reshape it into the map Flutter expects.
                        val json = JSONObject(credential.authenticationResponseJson)
                        val res = json.getJSONObject("response")
                        val map = hashMapOf<String, Any?>(
                            "id" to json.optString("id"),
                            "rawId" to json.optString("rawId"),
                            "type" to json.optString("type", "public-key"),
                            "authenticatorAttachment" to
                                json.optString("authenticatorAttachment", "platform"),
                            "response" to hashMapOf<String, Any?>(
                                "clientDataJSON" to res.optString("clientDataJSON"),
                                "authenticatorData" to res.optString("authenticatorData"),
                                "signature" to res.optString("signature"),
                                "userHandle" to
                                    if (res.has("userHandle")) res.optString("userHandle")
                                    else null
                            )
                        )
                        activity.runOnUiThread { result.success(map) }
                    } else {
                        activity.runOnUiThread {
                            result.error(
                                "unexpected_credential",
                                "Unexpected credential type: ${credential.type}",
                                null
                            )
                        }
                    }
                }

                override fun onError(e: GetCredentialException) {
                    val code = if (e is GetCredentialCancellationException) {
                        "canceled"
                    } else {
                        "passkey_error"
                    }
                    activity.runOnUiThread { result.error(code, e.message, null) }
                }
            }
        )
    }

    // MARK: Signup (attestation)

    private fun getAttestation(
        activity: Activity,
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val authParamsPublicKey = call.argument<Map<String, Any?>>("authParamsPublicKey")
        if (authParamsPublicKey == null) {
            result.error("bad_args", "Missing authParamsPublicKey", null)
            return
        }

        // Credential Manager expects the WebAuthn creation options as JSON.
        val requestJson = JSONObject(authParamsPublicKey).toString()
        val createRequest = CreatePublicKeyCredentialRequest(requestJson)
        val credentialManager = CredentialManager.create(activity)

        credentialManager.createCredentialAsync(
            activity,
            createRequest,
            CancellationSignal(),
            Executors.newSingleThreadExecutor(),
            object :
                CredentialManagerCallback<CreateCredentialResponse, CreateCredentialException> {
                override fun onResult(response: CreateCredentialResponse) {
                    if (response is CreatePublicKeyCredentialResponse) {
                        // registrationResponseJson is the standard WebAuthn
                        // attestation; reshape it into the map Flutter expects.
                        val json = JSONObject(response.registrationResponseJson)
                        val res = json.getJSONObject("response")
                        val map = hashMapOf<String, Any?>(
                            "id" to json.optString("id"),
                            "rawId" to json.optString("rawId"),
                            "type" to json.optString("type", "public-key"),
                            "authenticatorAttachment" to
                                json.optString("authenticatorAttachment", "platform"),
                            "response" to hashMapOf<String, Any?>(
                                "clientDataJSON" to res.optString("clientDataJSON"),
                                "attestationObject" to res.optString("attestationObject")
                            )
                        )
                        activity.runOnUiThread { result.success(map) }
                    } else {
                        activity.runOnUiThread {
                            result.error(
                                "unexpected_credential",
                                "Unexpected credential type: ${response.type}",
                                null
                            )
                        }
                    }
                }

                override fun onError(e: CreateCredentialException) {
                    val code = if (e is CreateCredentialCancellationException) {
                        "canceled"
                    } else {
                        "passkey_error"
                    }
                    activity.runOnUiThread { result.error(code, e.message, null) }
                }
            }
        )
    }
}
