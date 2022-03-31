package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterWebAuthMethodCallHandler: MethodCallHandler {
    private val WEBAUTH_LOGIN_METHOD = "webAuth#login"
    private val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            WEBAUTH_LOGIN_METHOD -> {
                result.success(mapOf(
                    "accessToken" to "AccessToken",
                    "idToken" to "IdToken",
                    "refreshToken" to "RefreshToken",
                    "userProfile" to mapOf("name" to "John Doe"),
                    "expiresIn" to 10,
                    "scopes" to listOf("a", "b")
                ))
            }
            WEBAUTH_LOGOUT_METHOD -> {
                result.success("Web Auth Logout Success")
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
