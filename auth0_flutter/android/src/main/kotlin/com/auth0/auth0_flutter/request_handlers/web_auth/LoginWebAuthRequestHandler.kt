package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.jwt.JWT
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.createUserProfileFromClaims
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class LoginWebAuthRequestHandler(private val builderResolver: (MethodCallRequest) -> WebAuthProvider.Builder) : WebAuthRequestHandler {
    override val method: String = "webAuth#login";

    override fun handle(
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val builder = builderResolver(request);
        val args = request.data
        val scopes = args.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>

        if (scopes.isNotEmpty()) {
            builder.withScope(scopes.joinToString(separator = " "))
        }

        if (args.getOrDefault("audience", null) is String) {
            builder.withAudience(args["audience"] as String)
        }

        if (args.getOrDefault("redirectUri", null) is String) {
            builder.withRedirectUri(args["redirectUri"] as String)
        }

        if (args.getOrDefault("organizationId", null) is String) {
            builder.withOrganization(args["organizationId"] as String)
        }

        if (args.getOrDefault("invitationUrl", null) is String) {
            builder.withInvitationUrl(args["invitationUrl"] as String)
        }

        if (args.getOrDefault("leeway", null) is Int) {
            builder.withIdTokenVerificationLeeway(args["leeway"] as Int)
        }

        if (args.getOrDefault("maxAge", null) is Int) {
            builder.withMaxAge(args["maxAge"] as Int)
        }

        if (args.getOrDefault("issuer", null) is String) {
            builder.withIdTokenVerificationIssuer(args["issuer"] as String)
        }

        if (args.getOrDefault("scheme", null) is String) {
            builder.withScheme(args["scheme"] as String)
        }

        if (args.getOrDefault("parameters", null) is Map<*, *>) {
            builder.withParameters(args["parameters"] as Map<String, *>)
        }

        builder.start(context, object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception)
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val jwt = JWT(credentials.idToken)

                // Map all claim values to their underlying type as Any
                val userProfile = createUserProfileFromClaims(jwt.claims)
                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)

                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to userProfile.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scopes
                    )
                )
            }
        })
    }
}
