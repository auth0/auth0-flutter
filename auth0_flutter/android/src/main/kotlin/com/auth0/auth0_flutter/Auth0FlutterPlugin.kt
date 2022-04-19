package com.auth0.auth0_flutter

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

internal const val WEBAUTH_LOGIN_METHOD = "webAuth#login"
internal const val WEBAUTH_LOGOUT_METHOD = "webAuth#logout"

/** Auth0FlutterPlugin */
class Auth0FlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  val handlerResolver = { call: MethodCall, request: MethodCallRequest ->
    when(call.method) {
        WEBAUTH_LOGIN_METHOD -> LoginWebAuthRequestHandler(WebAuthProvider.login(request.account))
        WEBAUTH_LOGOUT_METHOD -> LogoutWebAuthRequestHandler(WebAuthProvider.logout(request.account))
        else -> null
    }
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var webAuthMethodChannel : MethodChannel
  private lateinit var authMethodChannel : MethodChannel
  private val webAuthCallHandler = Auth0FlutterWebAuthMethodCallHandler(handlerResolver)
  private val authCallHandler = Auth0FlutterAuthMethodCallHandler()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    webAuthMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0.com/auth0_flutter/web_auth")
    webAuthMethodChannel.setMethodCallHandler(webAuthCallHandler)

    authMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0.com/auth0_flutter/auth")
    authMethodChannel.setMethodCallHandler(authCallHandler)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {}

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    webAuthMethodChannel.setMethodCallHandler(null)
    authMethodChannel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    webAuthCallHandler.context = binding.activity
    authCallHandler.context = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // Not yet implemented
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    // Not yet implemented
  }

  override fun onDetachedFromActivity() {
    // Not yet implemented
  }
}
