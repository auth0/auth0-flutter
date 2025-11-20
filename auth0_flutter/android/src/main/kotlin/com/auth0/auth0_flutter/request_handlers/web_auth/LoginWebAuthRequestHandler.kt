package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
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

        val allowedBrowsers = (args["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
        if(allowedBrowsers.isNotEmpty()) {
            builder.withCustomTabsOptions(
                CustomTabsOptions.newBuilder().withBrowserPicker(
                    BrowserPicker.newBuilder()
                        .withAllowedPackages(allowedBrowsers).build()
                ).build()
            )
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

        // Enable DPoP when requested from Dart.
        if (args["useDPoP"] as? Boolean == true) {
            var enabled = false
            try {
                val method = builder.javaClass.getMethod("useDPoP", android.content.Context::class.java)
                method.invoke(builder, context)
                enabled = true
            } catch (ignored: NoSuchMethodException) {
            } catch (e: Exception) {
                android.util.Log.w("Auth0Flutter", "Failed to enable DPoP on Builder: ${e.message}")
            }

            if (!enabled) {
                try {
                    val wpClass = WebAuthProvider::class.java
                    val instanceField = try { wpClass.getField("INSTANCE") } catch (e: NoSuchFieldException) { null }
                    val instance = instanceField?.get(null)
                    if (instance != null) {
                        val method = wpClass.getMethod("useDPoP", android.content.Context::class.java)
                        method.invoke(instance, context)
                        enabled = true
                    } else {
                        val staticMethod = try { wpClass.getMethod("useDPoP", android.content.Context::class.java) } catch (e: NoSuchMethodException) { null }
                        if (staticMethod != null) {
                            staticMethod.invoke(null, context)
                            enabled = true
                        }
                    }
                } catch (e: NoSuchMethodException) {
                    android.util.Log.w("Auth0Flutter", "DPoP not supported by this version of Auth0.Android SDK.")
                } catch (e: Exception) {
                    android.util.Log.w("Auth0Flutter", "Failed to enable DPoP via WebAuthProvider: ${e.message}")
                }
            }

            if (!enabled) {
                android.util.Log.w("Auth0Flutter", "DPoP was requested but could not be enabled on this SDK version.")
            } else {
                android.util.Log.v("Auth0Flutter", "DPoP enabled for this WebAuth flow")
            }
        }

        builder.start(context, object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception)
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scopes = credentials.scope?.split(" ") ?: listOf()
                val formattedDate = credentials.expiresAt.toInstant().toString()

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
