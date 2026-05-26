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

class LoginWebAuthRequestHandler(
    private val builderProvider: (com.auth0.android.Auth0) -> WebAuthProvider.Builder = { account -> WebAuthProvider.login(account) }
) : WebAuthRequestHandler {
    override val method: String = "webAuth#login"

    override fun handle(
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val builder = builderProvider(request.account)
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

        val customTabsOptionsMap = args["customTabsOptions"] as? Map<*, *>
        val allowedBrowsers = if (customTabsOptionsMap != null) {
            (customTabsOptionsMap["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
        } else {
            (args["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
        }

        if (customTabsOptionsMap != null || allowedBrowsers.isNotEmpty()) {
            val ctBuilder = CustomTabsOptions.newBuilder()

            if (allowedBrowsers.isNotEmpty()) {
                ctBuilder.withBrowserPicker(
                    BrowserPicker.newBuilder()
                        .withAllowedPackages(allowedBrowsers).build()
                )
            }

            if (customTabsOptionsMap != null) {
                val initialHeight = customTabsOptionsMap["initialHeight"] as? Int
                if (initialHeight != null && initialHeight > 0) {
                    ctBuilder.withInitialHeight(initialHeight)
                }

                val resizable = customTabsOptionsMap["resizable"] as? Boolean
                if (resizable != null) {
                    ctBuilder.withResizable(resizable)
                }

                val toolbarCornerRadius = customTabsOptionsMap["toolbarCornerRadius"] as? Int
                if (toolbarCornerRadius != null && toolbarCornerRadius > 0) {
                    ctBuilder.withToolbarCornerRadius(toolbarCornerRadius)
                }

                val initialWidth = customTabsOptionsMap["initialWidth"] as? Int
                if (initialWidth != null && initialWidth > 0) {
                    ctBuilder.withInitialWidth(initialWidth)
                }

                val sideSheetBreakpoint = customTabsOptionsMap["sideSheetBreakpoint"] as? Int
                if (sideSheetBreakpoint != null && sideSheetBreakpoint > 0) {
                    ctBuilder.withSideSheetBreakpoint(sideSheetBreakpoint)
                }

                val backgroundInteractionEnabled = customTabsOptionsMap["backgroundInteractionEnabled"] as? Boolean
                if (backgroundInteractionEnabled == true) {
                    ctBuilder.withBackgroundInteractionEnabled(true)
                }
            }

            builder.withCustomTabsOptions(ctBuilder.build())
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

        if (args["useDPoP"] == true) {
            WebAuthProvider.useDPoP(context)
        }

        builder.start(context, object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                val details = mutableMapOf<String, Any>("_isRetryable" to exception.isNetworkError)
                exception.cause?.let {
                    details["cause"] = it.toString()
                    details["causeStackTrace"] = it.stackTraceToString()
                }
                result.error(exception.getCode(), exception.getDescription(), details)
            }

            override fun onSuccess(credentials: Credentials) {
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