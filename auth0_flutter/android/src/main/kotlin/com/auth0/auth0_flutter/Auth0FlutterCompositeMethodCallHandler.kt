package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Composite handler that delegates method calls to either DPoP or Auth handlers.
 * DPoP handlers are tried first, then falls back to Auth handlers.
 */
class Auth0FlutterCompositeMethodCallHandler(
    private val dpopHandler: Auth0FlutterDPoPMethodCallHandler,
    private val authHandler: Auth0FlutterAuthMethodCallHandler
) : MethodCallHandler {
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        // Track if the method was handled
        var handled = false
        
        // Create a result wrapper to detect if DPoP handler processed the call
        val dpopResult = object : Result {
            override fun success(data: Any?) {
                handled = true
                result.success(data)
            }
            
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                handled = true
                result.error(errorCode, errorMessage, errorDetails)
            }
            
            override fun notImplemented() {
                // DPoP didn't handle it, don't mark as handled
                handled = false
            }
        }
        
        // Try DPoP handler first
        dpopHandler.onMethodCall(call, dpopResult)
        
        // If DPoP didn't handle it, try auth handler
        if (!handled) {
            authHandler.onMethodCall(call, result)
        }
    }
}
