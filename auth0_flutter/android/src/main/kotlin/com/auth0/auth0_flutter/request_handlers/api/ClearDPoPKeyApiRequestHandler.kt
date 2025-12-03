package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.dpop.DPoP
import com.auth0.android.dpop.DPoPException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_CLEAR_DPOP_KEY_METHOD = "auth#clearDPoPKey"

/**
 * Handles clearDPoPKey method call. Uses the DPoP utility class directly
 * to clear the stored DPoP key pair, matching the approach used in React Native Auth0.
 */
class ClearDPoPKeyApiRequestHandler : UtilityRequestHandler {
    override val method: String = AUTH_CLEAR_DPOP_KEY_METHOD

    override fun handle(
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        try {
            // Use DPoP class directly (same approach as React Native Auth0)
            // This clears the stored DPoP key pair
            DPoP.clearKeyPair()
            result.success(null)
        } catch (e: DPoPException) {
            // Handle DPoP-specific exceptions
            result.error(
                "DPOP_ERROR",
                e.message ?: "Failed to clear DPoP key",
                mapOf(
                    "errorType" to e.javaClass.simpleName
                )
            )
        } catch (e: Exception) {
            // Handle general exceptions
            result.error(
                "CLEAR_DPOP_KEY_ERROR",
                e.message ?: "Failed to clear DPoP key",
                null
            )
        }
    }
}
