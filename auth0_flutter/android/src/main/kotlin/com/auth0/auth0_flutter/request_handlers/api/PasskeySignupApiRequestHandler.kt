package com.auth0.auth0_flutter.request_handlers.api

import android.app.Activity
import android.content.Context
import android.os.Build
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSKEY_SIGNUP_METHOD = "auth#passkeySignup"

/**
 * Exchanges a passkey credential (presented by the app) and a signup challenge
 * for Auth0 tokens by calling the `/oauth/token` endpoint. This handler does not
 * present any UI.
 */
class PasskeySignupApiRequestHandler : PasskeyApiRequestHandler {
    override val method: String = AUTH_PASSKEY_SIGNUP_METHOD

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

        val authSession = challengeMap["authSession"] as? String
        if (authSession == null) {
            result.error("PASSKEY_ERROR", "Missing authSession in challenge", null)
            return
        }

        val credentialMap = args["credential"] as? Map<*, *>
        if (credentialMap == null) {
            result.error("PASSKEY_ERROR", "Missing credential argument", null)
            return
        }

        val connection = args["connection"] as? String
        val organization = args["organization"] as? String
        val audience = args["audience"] as? String
        val scopes = (args["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        val parameters = (args["parameters"] as? Map<*, *>)?.mapKeys { it.key.toString() }
            ?.mapValues { it.value.toString() } ?: emptyMap()

        // signinWithPasskey accepts the WebAuthn registration response as a JSON
        // string in the standard format produced by the create-credential step.
        val authResponseJson = Gson().toJson(credentialMap)

        val signupBuilder = api.signinWithPasskey(
            authSession,
            authResponseJson,
            connection,
            organization
        )
            .validateClaims()

        if (scopes.isNotEmpty()) {
            signupBuilder.setScope(scopes.joinToString(separator = " "))
        }
        if (audience != null) {
            signupBuilder.setAudience(audience)
        }
        if (parameters.isNotEmpty()) {
            signupBuilder.addParameters(parameters)
        }

        signupBuilder.start(object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                val scope = credentials.scope?.split(" ") ?: listOf()
                val formattedDate = credentials.expiresAt.toInstant().toString()
                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to credentials.user.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scope,
                        "tokenType" to credentials.type
                    )
                )
            }
        })
    }
}
