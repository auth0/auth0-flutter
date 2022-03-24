package com.auth0.auth0_flutter


import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Auth0FlutterPlugin */
class Auth0FlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private val WEBAUTH_LOGIN_METHOD = "webAuth#login"
  private val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"
  private val AUTH_LOGIN_METHOD = "auth#login"
  private val AUTH_CODEEXCHANGE_METHOD = "auth#codeExchange"
  private val AUTH_USERINFO_METHOD = "auth#userInfo"
  private val AUTH_SIGNUP_METHOD = "auth#signUp"
  private val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
  private val AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0.com/auth0_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      WEBAUTH_LOGIN_METHOD -> {
        result.success(mapOf(
          "accessToken" to "AccessToken",
          "idToken" to "IdToken",
          "refreshToken" to "RefreshToken",
          "userProfile" to "UserProfile",
          "expiresIn" to "ExpiresIn",
          "scopes" to "Scopes"
        ))
      }
      WEBAUTH_LOGOUT_METHOD -> {
        result.success("Web Auth Logout Success")
      }
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
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
