package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
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
  private lateinit var dpopMethodChannel : MethodChannel
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding
  private lateinit var authCallHandler: Auth0FlutterAuthMethodCallHandler
  private var pendingRecoveredCredentials: Map<String, Any?>? = null
  private var pendingRecoveryError: Map<String, Any?>? = null
  private var dartReady = false
  private val webAuthCallHandler = Auth0FlutterWebAuthMethodCallHandler(listOf(
    LoginWebAuthRequestHandler(),
    LogoutWebAuthRequestHandler { request: MethodCallRequest -> WebAuthProvider.logout(request.account) },
  ))
  private val credentialsManagerCallHandler = CredentialsManagerMethodCallHandler(listOf(
    GetCredentialsRequestHandler(),
    GetSSOCredentialsRequestHandler(),
    RenewCredentialsRequestHandler(),
    SaveCredentialsRequestHandler(),
    HasValidCredentialsRequestHandler(),
    ClearCredentialsRequestHandler(),
    GetCredentialsUserInfoRequestHandler()
  ))
  private val dpopCallHandler = Auth0FlutterDPoPMethodCallHandler(listOf(
    GetDPoPHeadersApiRequestHandler(),
    ClearDPoPKeyApiRequestHandler()
  ))

  private val processDeathCallback = object : Callback<Credentials, AuthenticationException> {
    override fun onSuccess(credentials: Credentials) {
      val scopes = credentials.scope?.split(" ") ?: listOf()
      val formattedDate = credentials.expiresAt.toInstant().toString()

      val credentialsMap = mapOf(
        "accessToken" to credentials.accessToken,
        "idToken" to credentials.idToken,
        "refreshToken" to credentials.refreshToken,
        "userProfile" to credentials.user.toMap(),
        "expiresAt" to formattedDate,
        "scopes" to scopes,
        "tokenType" to credentials.type
      )

      if (dartReady) {
        webAuthMethodChannel.invokeMethod("webAuth#onLoginResult", credentialsMap)
      } else {
        pendingRecoveredCredentials = credentialsMap
        pendingRecoveryError = null
      }
    }

    override fun onFailure(exception: AuthenticationException) {
      val errorMap = mapOf(
        "code" to exception.getCode(),
        "description" to exception.getDescription(),
        "_isRetryable" to exception.isNetworkError
      )

      if (dartReady) {
        webAuthMethodChannel.invokeMethod("webAuth#onLoginError", errorMap)
      } else {
        pendingRecoveryError = errorMap
        pendingRecoveredCredentials = null
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binding = flutterPluginBinding
    val messenger = binding.binaryMessenger
    val context = binding.applicationContext

    webAuthMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/web_auth")
    webAuthMethodChannel.setMethodCallHandler(this)

    credentialsManagerMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/credentials_manager")
    credentialsManagerMethodChannel.setMethodCallHandler(credentialsManagerCallHandler)
    credentialsManagerCallHandler.context = context

    authCallHandler = Auth0FlutterAuthMethodCallHandler(
      listOf(
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
        CustomTokenExchangeApiRequestHandler(),
        SSOExchangeApiRequestHandler(),
        ResetPasswordApiRequestHandler()
      )
    )
    authCallHandler.context = context

    authMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/auth")
    authMethodChannel.setMethodCallHandler(authCallHandler)

    dpopMethodChannel = MethodChannel(messenger, "auth0.com/auth0_flutter/dpop")
    dpopMethodChannel.setMethodCallHandler(dpopCallHandler)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "webAuth#dartReady" -> {
        dartReady = true
        pendingRecoveredCredentials?.let {
          webAuthMethodChannel.invokeMethod("webAuth#onLoginResult", it)
          pendingRecoveredCredentials = null
        }
        pendingRecoveryError?.let {
          webAuthMethodChannel.invokeMethod("webAuth#onLoginError", it)
          pendingRecoveryError = null
        }
        result.success(null)
      }
      else -> webAuthCallHandler.onMethodCall(call, result)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    webAuthMethodChannel.setMethodCallHandler(null)
    authMethodChannel.setMethodCallHandler(null)
    credentialsManagerMethodChannel.setMethodCallHandler(null)
    dpopMethodChannel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    webAuthCallHandler.activity = binding.activity
    credentialsManagerCallHandler.activity = binding.activity
    WebAuthProvider.addCallback(processDeathCallback)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    WebAuthProvider.removeCallback(processDeathCallback)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    webAuthCallHandler.activity = binding.activity
    credentialsManagerCallHandler.activity = binding.activity
    WebAuthProvider.addCallback(processDeathCallback)
  }

  override fun onDetachedFromActivity() {
    WebAuthProvider.removeCallback(processDeathCallback)
  }
}
