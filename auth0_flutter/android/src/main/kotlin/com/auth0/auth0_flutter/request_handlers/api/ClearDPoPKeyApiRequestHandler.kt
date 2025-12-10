package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.dpop.DPoP
import com.auth0.android.dpop.DPoPException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_CLEAR_DPOP_KEY_METHOD = "dpop#clearDPoPKey"

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
            DPoP.clearKeyPair()
            result.success(null)
        } catch (e: DPoPException) {
            result.error(
                "DPOP_ERROR",
                e.message ?: "Failed to clear DPoP key",
                mapOf(
                    "errorType" to e.javaClass.simpleName
                )
            )
        } catch (e: Exception) {
            result.error(
                "CLEAR_DPOP_KEY_ERROR",
                e.message ?: "Failed to clear DPoP key",
                null
            )
        }
    }
}
