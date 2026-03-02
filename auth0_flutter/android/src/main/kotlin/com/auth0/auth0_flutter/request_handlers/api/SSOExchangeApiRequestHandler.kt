package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.SSOCredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_SSO_EXCHANGE_METHOD = "auth#ssoExchange"

class SSOExchangeApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_SSO_EXCHANGE_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("refreshToken"), request.data)

        val builder = api.ssoExchange(request.data["refreshToken"] as String)

        if (request.data["parameters"] is HashMap<*, *>) {
            builder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        if (request.data["headers"] is HashMap<*, *>) {
            (request.data["headers"] as Map<String, String>).forEach { (key, value) ->
                builder.addHeader(key, value)
            }
        }

        builder.start(object : Callback<SSOCredentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(credentials: SSOCredentials) {
                val map = mutableMapOf<String, Any?>(
                    "sessionTransferToken" to credentials.sessionTransferToken,
                    "tokenType" to credentials.issuedTokenType,
                    "expiresIn" to credentials.expiresIn,
                    "idToken" to credentials.idToken
                )
                credentials.refreshToken?.let { map["refreshToken"] = it }
                result.success(map)
            }
        })
    }
}
