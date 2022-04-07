package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback;
import com.auth0.android.result.DatabaseUser
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterAuthMethodCallHandler : MethodCallHandler {
    private val AUTH_LOGIN_METHOD = "auth#login"
    private val AUTH_USERINFO_METHOD = "auth#userInfo"
    private val AUTH_SIGNUP_METHOD = "auth#signUp"
    private val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
    private val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            AUTH_LOGIN_METHOD -> {
                result.success("Auth Login Success")
            }
            AUTH_USERINFO_METHOD -> {
                result.success("Auth User Info Success")
            }
            AUTH_SIGNUP_METHOD -> {
                val args = call.arguments as HashMap<*, *>;
                val authentication = AuthenticationAPIClient(
                    Auth0(
                        args["clientId"] as String,
                        args["domain"] as String
                    )
                );

                authentication.createUser(
                    email = args["email"] as String,
                    password = args["password"] as String,
                    username = args["username"] as String?,
                    connection = args["connection"] as String,
                    userMetadata = args["userMetadata"] as Map<String, String>
                ).start(object : Callback<DatabaseUser, AuthenticationException> {
                    override fun onFailure(exception: AuthenticationException) {
                        result.error(
                            exception.getCode(),
                            exception.getDescription(),
                            exception.toMap()
                        );
                    }

                    override fun onSuccess(user: DatabaseUser) {
                        result.success(
                            mapOf(
                                "emailVerified" to user.isEmailVerified,
                                "email" to user.email,
                                "username" to user.username
                            )
                        )
                    }
                });
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
