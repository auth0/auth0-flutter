package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

/**
 * Interface for request handlers for utility operations like DPoP key management that use static methods.
 */
interface UtilityRequestHandler {
    val method: String
    fun handle(request: MethodCallRequest, result: MethodChannel.Result)
}
