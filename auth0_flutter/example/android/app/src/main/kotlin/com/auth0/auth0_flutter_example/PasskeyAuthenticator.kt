package com.auth0.auth0_flutter_example

import android.app.Activity
import android.os.Build
import android.os.CancellationSignal
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.concurrent.Executors

/**
 * Presents the Android Credential Manager passkey UI and returns a WebAuthn
 * assertion to Flutter.
 *
 * This lives in the example app — not the `auth0_flutter` SDK — to demonstrate
 * how an app supplies the passkey credential that `auth0.api.passkeyLogin`
 * expects, using the `challenge` and `rpId` from `auth0.api.passkeyLoginChallenge`.
 */
class PasskeyAuthenticator(private val activity: Activity) {

    companion object {
        const val CHANNEL_NAME = "com.auth0.auth0_flutter_example/passkey"
    }

    fun handle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        if (call.method != "getAssertion") {
            result.notImplemented()
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("unsupported", "Passkeys require Android 9 (API 28)+", null)
            return
        }

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
}
