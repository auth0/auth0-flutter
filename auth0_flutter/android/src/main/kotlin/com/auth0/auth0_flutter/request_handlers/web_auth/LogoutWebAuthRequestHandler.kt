package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class LogoutWebAuthRequestHandler(private val builderResolver: (MethodCallRequest) -> WebAuthProvider.LogoutBuilder) : WebAuthRequestHandler {
    override val method: String = "webAuth#logout"

    override fun handle(context: Context, request: MethodCallRequest, result: MethodChannel.Result) {
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

        val allowedBrowsers = (args["allowedBrowsers"] as? List<*>)?.filterIsInstance<String>().orEmpty()
        if(allowedBrowsers.isNotEmpty()) {
            builder.withCustomTabsOptions(
                CustomTabsOptions.newBuilder().withBrowserPicker(
                    BrowserPicker.newBuilder()
                        .withAllowedPackages(allowedBrowsers).build()
                ).build()
            )
        }

        builder.start(context, object: Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception)
            }

            override fun onSuccess(res: Void?) {
                result.success(null)
            }
        })
    }
}
