package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Auth0FlutterAuthMethodCallHandler: MethodCallHandler {

    private val AUTH_LOGIN_METHOD = "auth#login"
    private val AUTH_CODEEXCHANGE_METHOD = "auth#codeExchange"
    private val AUTH_USERINFO_METHOD = "auth#userInfo"
    private val AUTH_SIGNUP_METHOD = "auth#signUp"
    private val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
    private val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            AUTH_LOGIN_METHOD -> {
                result.success("Auth Login Success")
            }
            AUTH_CODEEXCHANGE_METHOD -> {
                result.success("Auth Code Exchange Success")
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
        }
    }
}
