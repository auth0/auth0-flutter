package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.android.jwt.JWT
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

class Auth0FlutterWebAuthMethodCallHandler : MethodCallHandler {
    private val WEBAUTH_LOGIN_METHOD = "webAuth#login"
    private val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"
    lateinit var context: Context

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        val callback = object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scope = credentials.scope?.split(" ") ?: listOf()

                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)
                val jwt = JWT(credentials.idToken)
                val allClaims = jwt.claims.mapValues { it.value.asString() }

                result.success(mapOf(
                    "accessToken" to credentials.accessToken,
                    "idToken" to credentials.idToken,
                    "refreshToken" to credentials.refreshToken,
                    "userProfile" to allClaims,
                    "expiresAt" to formattedDate,
                    "scopes" to scope
                ))
            }
        }

        val logoutCallback = object: Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(res: Void?) {
                result.success(null);
            }
        }

        when (call.method) {

            WEBAUTH_LOGIN_METHOD -> {
                val args = call.arguments as HashMap<*, *>;

                val loginBuilder = WebAuthProvider
                    .login(Auth0(args["clientId"] as String, args["domain"] as String))

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

                loginBuilder.start(context, callback)
            }
            WEBAUTH_LOGOUT_METHOD -> {
                val args = call.arguments as HashMap<*, *>;

                val logoutBuilder = WebAuthProvider
                    .logout(Auth0(args["clientId"] as String, args["domain"] as String))

                if (args.getOrDefault("scheme", null) is String) {
                    logoutBuilder.withScheme(args["scheme"] as String)
                }

                if (args.getOrDefault("returnTo", null) is String) {
                    logoutBuilder.withReturnToUrl(args["returnTo"] as String)
                }

                logoutBuilder.start(context, logoutCallback)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
