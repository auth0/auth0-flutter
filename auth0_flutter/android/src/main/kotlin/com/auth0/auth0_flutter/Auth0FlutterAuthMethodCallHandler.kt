package com.auth0.auth0_flutter

import android.content.Context
import androidx.annotation.NonNull
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.android.authentication.storage.SharedPreferencesStorage
import com.auth0.android.callback.Callback
import com.auth0.android.provider.AuthProvider
import com.auth0.android.result.Credentials
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

class Auth0FlutterAuthMethodCallHandler: MethodCallHandler {
    private val AUTH_LOGIN_METHOD = "auth#login"
    private val AUTH_USERINFO_METHOD = "auth#userInfo"
    private val AUTH_SIGNUP_METHOD = "auth#signUp"
    private val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
    private val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

    lateinit var context: Context;


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        when (call.method) {
            AUTH_LOGIN_METHOD -> {
                val args = call.arguments as HashMap<*, *>;
                val authentication = AuthenticationAPIClient(Auth0(args["clientId"] as String, args["domain"] as String));

                authentication
                    .login(args["usernameOrEmail"] as String, args["password"] as String, args["connectionOrRealm"] as String)
                    .setScope((args["scope"] as List<String>).joinToString(separator = " "))
                    .addParameters(args["parameters"] as Map<String, String>)
                    .start(object : Callback<Credentials, AuthenticationException> {
                        override fun onFailure(exception: AuthenticationException) {
                            result.error(
                                exception.getCode(),
                                exception.getDescription(),
                                exception
                            );
                        }

                        override fun onSuccess(credentials: Credentials) {
                            val scope = credentials.scope?.split(" ") ?: listOf()
                            val sdf =
                                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                            val formattedDate = sdf.format(credentials.expiresAt)
                            result.success(
                                mapOf(
                                    "accessToken" to credentials.accessToken,
                                    "idToken" to credentials.idToken,
                                    "refreshToken" to credentials.refreshToken,
                                    "userProfile" to mapOf<String, String>(),
                                    "expiresAt" to formattedDate,
                                    "scopes" to scope
                                )
                            )
                        }
                    });
            }
            AUTH_USERINFO_METHOD -> {
                result.success("Auth User Info Success")
            }
            AUTH_SIGNUP_METHOD -> {
                result.success("Auth SignUp Success")
            }
            AUTH_RENEWACCESSTOKEN_METHOD -> {
                result.success("Auth Renew Access Token Success")
            }
            AUTH_RESETPASSWORD_METHOD -> {
                result.success("Auth Reset Password Success")
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
