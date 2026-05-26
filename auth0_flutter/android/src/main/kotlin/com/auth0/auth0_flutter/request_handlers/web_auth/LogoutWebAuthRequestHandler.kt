package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class LogoutWebAuthRequestHandler(private val builderResolver: (MethodCallRequest) -> WebAuthProvider.LogoutBuilder) :
    WebAuthRequestHandler {
    override val method: String = "webAuth#logout"

    override fun handle(
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val builder = builderResolver(request)
        val args = request.data

        if (args["scheme"] is String) {
            builder.withScheme(args["scheme"] as String)
        }

        if (args["returnTo"] is String) {
            builder.withReturnToUrl(args["returnTo"] as String)
        }

        if (args["federated"] as? Boolean == true) {
            builder.withFederated()
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

        builder.start(context, object : Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                val details = mutableMapOf<String, Any>("_isRetryable" to exception.isNetworkError)
                exception.cause?.let {
                    details["cause"] = it.toString()
                    details["causeStackTrace"] = it.stackTraceToString()
                }
                result.error(exception.getCode(), exception.getDescription(), details)
            }

            override fun onSuccess(res: Void?) {
                result.success(null)
            }
        })
    }
}
