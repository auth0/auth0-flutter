package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
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

        assertHasProperties(listOf("challenge.authSession", "credential"), args)

        val authSession = (args["challenge"] as Map<*, *>)["authSession"] as String
        val credentialMap = args["credential"] as Map<*, *>

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
}
