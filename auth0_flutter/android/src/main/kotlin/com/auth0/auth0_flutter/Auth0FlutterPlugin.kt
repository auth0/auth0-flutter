package com.auth0.auth0_flutter


import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.auth0.auth0_flutter.Auth0FlutterAuthMethodCallHandler
import com.auth0.auth0_flutter.Auth0FlutterWebAuthMethodCallHandler


/** Auth0FlutterPlugin */
class Auth0FlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var methodCallHandlers = mutableListOf<MethodCallHandler>();

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "auth0.com/auth0_flutter")
    channel.setMethodCallHandler(this)
    methodCallHandlers.addAll(listOf(Auth0FlutterWebAuthMethodCallHandler(), Auth0FlutterAuthMethodCallHandler()))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    methodCallHandlers.forEach { it.onMethodCall(call, result) }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
