package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class LoginWebAuthRequestHandler(private val builderResolver: (MethodCallRequest) -> WebAuthProvider.Builder) : WebAuthRequestHandler {
    override val method: String = "webAuth#login"

    override fun handle(
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val builder = builderResolver(request)
        val args = request.data
        val scopes = (args["scopes"] ?: arrayListOf<String>()) as ArrayList<*>

        builder.withScope(scopes.joinToString(separator = " "))

        if (args["audience"] is String) {
            builder.withAudience(args["audience"] as String)
        }

        if (args["redirectUrl"] is String) {
            builder.withRedirectUri(args["redirectUrl"] as String)
        }

        if (args["organizationId"] is String) {
            builder.withOrganization(args["organizationId"] as String)
        }

        if (args["invitationUrl"] is String) {
            builder.withInvitationUrl(args["invitationUrl"] as String)
        }

        if (args["leeway"] is Int) {
            builder.withIdTokenVerificationLeeway(args["leeway"] as Int)
        }

        if (args["maxAge"] is Int) {
            builder.withMaxAge(args["maxAge"] as Int)
        }

        if (args["issuer"] is String) {
            builder.withIdTokenVerificationIssuer(args["issuer"] as String)
        }

        if (args["scheme"] is String) {
            builder.withScheme(args["scheme"] as String)
        }

        if (args["parameters"] is Map<*, *>) {
            builder.withParameters(args["parameters"] as Map<String, *>)
        }

        builder.start(context, object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception)
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)

                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to credentials.user.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scopes,
                        "tokenType" to credentials.type
                    )
                )
            }
        })
    }
}
