package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class LogoutWebAuthRequestHandler(private val builder: WebAuthProvider.LogoutBuilder) : WebAuthRequestHandler {
    override fun handle(context: Context, request: MethodCallRequest, result: MethodChannel.Result) {
        val args = request.data;

        if (args.getOrDefault("scheme", null) is String) {
            builder.withScheme(args["scheme"] as String)
        }

        if (args.getOrDefault("returnTo", null) is String) {
            builder.withReturnToUrl(args["returnTo"] as String)
        }

        builder.start(context, object: Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(res: Void?) {
                result.success(null);
            }
        })
    }
}
