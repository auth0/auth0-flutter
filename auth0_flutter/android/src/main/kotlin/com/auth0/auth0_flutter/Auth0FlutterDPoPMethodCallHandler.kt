package com.auth0.auth0_flutter

import androidx.annotation.NonNull
import com.auth0.auth0_flutter.request_handlers.api.UtilityRequestHandler
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Handler for DPoP-related method calls.
 * DPoP (Demonstration of Proof-of-Possession) operations use static utility methods
 * and don't require authentication API client instances.
 */
class Auth0FlutterDPoPMethodCallHandler(
    private val dpopRequestHandlers: List<UtilityRequestHandler>
) : MethodCallHandler {
    
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val request = MethodCallRequest.fromCall(call)
        
        // Find the matching DPoP handler
        val dpopHandler = dpopRequestHandlers.find { it.method == call.method }
        
        if (dpopHandler != null) {
            dpopHandler.handle(request, result)
        } else {
            result.notImplemented()
        }
    }
}
