package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import com.auth0.android.jwt.JWT
import com.auth0.auth0_flutter.utils.processClaims


private val WEBAUTH_LOGIN_METHOD = "webAuth#login"

class LoginWebAuthRequestHandler : WebAuthRequestHandler {
    override val method: String = WEBAUTH_LOGIN_METHOD

    override fun handle(context: Context, request: MethodCallRequest, result: MethodChannel.Result) {
        val loginBuilder = WebAuthProvider.login(request.account)

        val args = request.data;
        val scopes = args.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            loginBuilder.withScope(scopes.joinToString(separator = " "))
        }

        if (args.getOrDefault("audience", null) is String) {
            loginBuilder.withAudience(args["audience"] as String)
        }

        if (args.getOrDefault("redirectUri", null) is String) {
            loginBuilder.withRedirectUri(args["redirectUri"] as String)
        }

        if (args.getOrDefault("organizationId", null) is String) {
            loginBuilder.withOrganization(args["organizationId"] as String)
        }

        if (args.getOrDefault("invitationUrl", null) is String) {
            loginBuilder.withInvitationUrl(args["invitationUrl"] as String)
        }

        if (args.getOrDefault("leeway", null) is Int) {
            loginBuilder.withIdTokenVerificationLeeway(args["leeway"] as Int)
        }

        if (args.getOrDefault("maxAge", null) is Int) {
            loginBuilder.withMaxAge(args["maxAge"] as Int)
        }

        if (args.getOrDefault("issuer", null) is String) {
            loginBuilder.withIdTokenVerificationIssuer(args["issuer"] as String)
        }

        if (args.getOrDefault("scheme", null) is String) {
            loginBuilder.withScheme(args["scheme"] as String)
        }

        if (args.getOrDefault("parameters", hashMapOf<String, Any?>()) is HashMap<*, *>) {
            loginBuilder.withParameters(args["parameters"] as HashMap<String, *>)
        }

        loginBuilder.start(context, object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val jwt = JWT(credentials.idToken)

                // Map all claim values to their underlying type as Any
                val claims = processClaims(jwt.claims.mapValues { it.value.asObject(Any::class.java) })

                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)

                result.success(mapOf(
                    "accessToken" to credentials.accessToken,
                    "idToken" to credentials.idToken,
                    "refreshToken" to credentials.refreshToken,
                    "userProfile" to claims,
                    "expiresAt" to formattedDate,
                    "scopes" to scopes
                ))
            }
        })
    }


}
