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

/**
 * Shared base for the passkey login and signup token exchanges.
 *
 * Both flows finish identically: they hand the app-supplied WebAuthn credential
 * (a login assertion or a signup attestation) plus the challenge's `authSession`
 * to Auth0's `signinWithPasskey` and exchange them for tokens at the
 * `/oauth/token` endpoint. Auth0.Android's `signinWithPasskey` accepts the
 * credential as a JSON string and handles both assertion and attestation
 * payloads, so the only thing that varies between login and signup is the
 * method name. Neither flow presents any UI.
 */
abstract class PasskeyTokenExchangeApiRequestHandler : ApiRequestHandler {
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
        val scopes = (args["scopes"] as? List<*>)?.filterIsInstance<String>()
            ?.joinToString(" ") ?: ""
        val parameters = (args["parameters"] as? Map<*, *>)?.mapKeys { it.key.toString() }
            ?.mapValues { it.value.toString() } ?: emptyMap()

        // signinWithPasskey accepts the WebAuthn credential response as a JSON
        // string in the standard format produced by the platform authenticator.
        val authResponseJson = gson.toJson(credentialMap)

        val builder = api.signinWithPasskey(
            authSession,
            authResponseJson,
            connection,
            organization
        )
            .validateClaims()

        if (scopes.isNotEmpty()) {
            builder.setScope(scopes)
        }
        if (audience != null) {
            builder.setAudience(audience)
        }
        if (parameters.isNotEmpty()) {
            builder.addParameters(parameters)
        }

        builder.start(object : Callback<Credentials, AuthenticationException> {
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
