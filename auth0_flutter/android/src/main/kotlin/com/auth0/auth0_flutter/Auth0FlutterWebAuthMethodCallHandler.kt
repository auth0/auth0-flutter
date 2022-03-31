package com.auth0.auth0_flutter

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.DateFormat
import java.text.SimpleDateFormat

class Auth0FlutterWebAuthMethodCallHandler : MethodCallHandler {
    private val WEBAUTH_LOGIN_METHOD = "webAuth#login"
    private val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"
    lateinit var context: Context

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        val callback = object : Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                // Failure! Check the exception for details
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scope = credentials.scope?.split(" ") ?: listOf()

                result.success(mapOf(
                    "accessToken" to credentials.accessToken,
                    "idToken" to credentials.idToken,
                    "refreshToken" to credentials.refreshToken,
                    "userProfile" to mapOf<String, String>(),
                    "expiresAt" to credentials.expiresAt.time,
                    "scopes" to scope
                ))
            }
        }

        when (call.method) {
            WEBAUTH_LOGIN_METHOD -> {
                Log.d("DEBUG", context.packageName)
                WebAuthProvider
                    .login(Auth0("dk1lvC9QyrdALZeXNaiIOwjX9BlMNmpv", "elkdanger.eu.auth0.com"))
                    .withScheme("demo")
                    .start(context, callback)
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
