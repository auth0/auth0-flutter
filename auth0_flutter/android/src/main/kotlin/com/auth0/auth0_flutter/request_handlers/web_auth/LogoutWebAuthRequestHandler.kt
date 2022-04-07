package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter_.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"

class LogoutWebAuthRequestHandler : WebAuthRequestHandler {
    override val method: String = WEBAUTH_LOGOUT_METHOD

    override fun handle(context: Context, request: MethodCallRequest, result: MethodChannel.Result) {
        val logoutBuilder = WebAuthProvider.logout(request.account)

        var args = request.data;

        if (args.getOrDefault("scheme", null) is String) {
            logoutBuilder.withScheme(args["scheme"] as String)
        }

        if (args.getOrDefault("returnTo", null) is String) {
            logoutBuilder.withReturnToUrl(args["returnTo"] as String)
        }

        logoutBuilder.start(context, object: Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(res: Void?) {
                result.success(null);
            }
        })
    }
}
