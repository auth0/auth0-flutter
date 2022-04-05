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
                result.error(exception.getCode(), exception.getDescription(), exception);
            }

            override fun onSuccess(credentials: Credentials) {
                // Success! Access token and ID token are presents
                val scope = credentials.scope?.split(" ") ?: listOf()

                result.success(mapOf(
                    "accessToken" to credentials.accessToken,
                    "idToken" to credentials.idToken,
                    "refreshToken" to credentials.refreshToken,
                    "userProfile" to mapOf<String, String>(),
                    "expiresIn" to credentials.expiresAt.time.toDouble(),
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

                if (args.containsKey("scheme")) {
                    loginBuilder.withScheme(args["scheme"] as String)
                }

                loginBuilder.start(context, callback)
            }
            WEBAUTH_LOGOUT_METHOD -> {
                val args = call.arguments as HashMap<*, *>;

                val logoutBuilder = WebAuthProvider
                    .logout(Auth0(args["clientId"] as String, args["domain"] as String))

                if (args.containsKey("scheme")) {
                    logoutBuilder.withScheme(args["scheme"] as String)
                }

                logoutBuilder.start(context, logoutCallback)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
