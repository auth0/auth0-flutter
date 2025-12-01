package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.api.*
import com.auth0.auth0_flutter.request_handlers.credentials_manager.*
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** Auth0FlutterPlugin */
class Auth0FlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var webAuthMethodChannel : MethodChannel
  private lateinit var authMethodChannel : MethodChannel
  private lateinit var credentialsManagerMethodChannel : MethodChannel
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding
  private lateinit var authCallHandler: Auth0FlutterAuthMethodCallHandler
  private val webAuthCallHandler = Auth0FlutterWebAuthMethodCallHandler(listOf(
    LoginWebAuthRequestHandler(WebAuthProvider),
    LogoutWebAuthRequestHandler { request: MethodCallRequest -> WebAuthProvider.logout(request.account) },
  ))
  private val credentialsManagerCallHandler = CredentialsManagerMethodCallHandler(listOf(
    GetCredentialsRequestHandler(),
    RenewCredentialsRequestHandler(),
    SaveCredentialsRequestHandler(),
    HasValidCredentialsRequestHandler(),
    ClearCredentialsRequestHandler()
  ))

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binding = flutterPluginBinding
    val messenger = binding.binaryMessenger
    val context = binding.applicationContext

    webAuthMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/web_auth")
    webAuthMethodChannel.setMethodCallHandler(webAuthCallHandler)

    credentialsManagerMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/credentials_manager")
    credentialsManagerMethodChannel.setMethodCallHandler(credentialsManagerCallHandler)
    credentialsManagerCallHandler.context = context

    authCallHandler = Auth0FlutterAuthMethodCallHandler(listOf(
      LoginApiRequestHandler(),
      LoginWithOtpApiRequestHandler(),
      MultifactorChallengeApiRequestHandler(),
      EmailPasswordlessApiRequestHandler(),
      PhoneNumberPasswordlessApiRequestHandler(),
      LoginWithEmailCodeApiRequestHandler(),
      LoginWithSMSCodeApiRequestHandler(),
      SignupApiRequestHandler(),
      UserInfoApiRequestHandler(),
      RenewApiRequestHandler(),
      ResetPasswordApiRequestHandler()
    ))

    authMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/auth")
    authMethodChannel.setMethodCallHandler(authCallHandler)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {}

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    webAuthMethodChannel.setMethodCallHandler(null)
    authMethodChannel.setMethodCallHandler(null)
    credentialsManagerMethodChannel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    webAuthCallHandler.activity = binding.activity
    credentialsManagerCallHandler.activity = binding.activity
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
