package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.dpop.DPoP
import com.auth0.android.dpop.DPoPException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_GET_DPOP_HEADERS_METHOD = "auth#getDPoPHeaders"

/**
 * Handles getDPoPHeaders method call. Uses the DPoP utility class directly
 * to generate DPoP proof headers, matching the approach used in React Native Auth0.
 */
class GetDPoPHeadersApiRequestHandler : UtilityRequestHandler {
    override val method: String = AUTH_GET_DPOP_HEADERS_METHOD

    override fun handle(
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val url = request.data["url"] as? String
        val httpMethod = request.data["method"] as? String
        val accessToken = request.data["accessToken"] as? String
        val tokenType = request.data["tokenType"] as? String
        val nonce = request.data["nonce"] as? String

        // Validate required parameters
        if (url == null || httpMethod == null || accessToken == null || tokenType == null) {
            result.error(
                "INVALID_ARGUMENTS",
                "url, method, accessToken, and tokenType are required",
                null
            )
            return
        }

        try {
            // Check if token type is DPoP (case insensitive)
            if (!tokenType.equals("DPoP", ignoreCase = true)) {
                // If not DPoP, return Bearer token format
                val headers = mutableMapOf<String, String>()
                headers["authorization"] = "Bearer $accessToken"
                result.success(headers)
                return
            }

            // Use DPoP class directly (same approach as React Native Auth0)
            // This class is available in Auth0 Android SDK
            val headerData = if (!nonce.isNullOrEmpty()) {
                DPoP.getHeaderData(httpMethod, url, accessToken, tokenType, nonce)
            } else {
                DPoP.getHeaderData(httpMethod, url, accessToken, tokenType)
            }
            
            // Build result map with headers
            val resultMap = mutableMapOf<String, String>()
            resultMap["authorization"] = headerData.authorizationHeader
            
            // Add DPoP proof if available
            headerData.dpopProof?.let { proof ->
                resultMap["dpop"] = proof
            }
            
            result.success(resultMap)
        } catch (e: DPoPException) {
            // Handle DPoP-specific exceptions
            result.error(
                "DPOP_ERROR",
                e.message ?: "Failed to generate DPoP headers",
                mapOf(
                    "errorType" to e.javaClass.simpleName
                )
            )
        } catch (e: Exception) {
            // Handle general exceptions
            result.error(
                "GET_DPOP_HEADERS_ERROR",
                e.message ?: "Failed to generate DPoP headers",
                null
            )
        }
    }
}
