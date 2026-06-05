package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel

private const val AUTH_PASSKEY_LOGIN_METHOD = "auth#passkeyLogin"

/**
 * Exchanges a passkey credential (presented by the app) and a login challenge
 * for Auth0 tokens by calling the `/oauth/token` endpoint. This handler does
 * not present any UI.
 */
class PasskeyLoginApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_PASSKEY_LOGIN_METHOD

    private val gson = Gson()

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        val challengeMap = args["challenge"] as? Map<*, *> ?: run {
            failWith(result, "a0.passkey.invalid_request", "Missing challenge argument")
            return
        }

        val authSession = challengeMap["authSession"] as? String ?: run {
            failWith(result, "a0.passkey.invalid_request", "Missing authSession in challenge")
            return
        }

        val credentialMap = args["credential"] as? Map<*, *> ?: run {
            failWith(result, "a0.passkey.invalid_request", "Missing credential argument")
            return
        }

        val connection = args["connection"] as? String
        val organization = args["organization"] as? String
        val audience = args["audience"] as? String
        val scopes = (args["scopes"] as? List<*>)?.filterIsInstance<String>()?.joinToString(" ") ?: ""
        val parameters = (args["parameters"] as? Map<*, *>)?.mapKeys { it.key.toString() }
            ?.mapValues { it.value.toString() } ?: emptyMap()

        // signinWithPasskey accepts the WebAuthn authentication response as a
        // JSON string in the standard format produced by the create-credential
        // step.
        val authResponseJson = gson.toJson(credentialMap)

        val loginBuilder = api.signinWithPasskey(
            authSession,
            authResponseJson,
            connection,
            organization
        )
            .validateClaims()

        if (scopes.isNotEmpty()) {
            loginBuilder.setScope(scopes)
        }
        if (audience != null) {
            loginBuilder.setAudience(audience)
        }
        if (parameters.isNotEmpty()) {
            loginBuilder.addParameters(parameters)
        }

        loginBuilder.start(object : Callback<Credentials, AuthenticationException> {
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

    // Surfaces validation errors through the same AuthenticationException shape
    // used for runtime failures, so the Dart side always receives a populated
    // `details` map.
    private fun failWith(result: MethodChannel.Result, code: String, message: String) {
        val exception = AuthenticationException(code, message)
        result.error(exception.getCode(), exception.getDescription(), exception.toMap())
    }
}
