package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.dpop.DPoP
import com.auth0.android.dpop.DPoPException
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

private const val AUTH_GET_DPOP_HEADERS_METHOD = "dpop#getDPoPHeaders"

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

        if (url == null || httpMethod == null || accessToken == null || tokenType == null) {
            result.error(
                "INVALID_ARGUMENTS",
                "url, method, accessToken, and tokenType are required",
                null
            )
            return
        }

        try {
            if (!tokenType.equals("DPoP", ignoreCase = true)) {
                val headers = mutableMapOf<String, String>()
                headers["authorization"] = "Bearer $accessToken"
                result.success(headers)
                return
            }

            val headerData = if (!nonce.isNullOrEmpty()) {
                DPoP.getHeaderData(httpMethod, url, accessToken, tokenType, nonce)
            } else {
                DPoP.getHeaderData(httpMethod, url, accessToken, tokenType)
            }
            
            val resultMap = mutableMapOf<String, String>()
            resultMap["authorization"] = headerData.authorizationHeader
            
            headerData.dpopProof?.let { proof ->
                resultMap["dpop"] = proof
            }
            
            result.success(resultMap)
        } catch (e: DPoPException) {
            result.error(
                "DPOP_ERROR",
                e.message ?: "Failed to generate DPoP headers",
                mapOf(
                    "errorType" to e.javaClass.simpleName
                )
            )
        } catch (e: Exception) {
            result.error(
                "GET_DPOP_HEADERS_ERROR",
                e.message ?: "Failed to generate DPoP headers",
                null
            )
        }
    }
}
