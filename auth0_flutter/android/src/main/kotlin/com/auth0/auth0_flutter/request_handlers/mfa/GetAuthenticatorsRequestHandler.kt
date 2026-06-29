package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaListAuthenticatorsException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Authenticator
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaMap
import io.flutter.plugin.common.MethodChannel

private const val MFA_GET_AUTHENTICATORS_METHOD = "mfa#getAuthenticators"

class GetAuthenticatorsRequestHandler : MfaRequestHandler {
    override val method: String = MFA_GET_AUTHENTICATORS_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        @Suppress("UNCHECKED_CAST")
        val factorsAllowed = (request.data["factorsAllowed"] as? List<String>) ?: listOf()

        client.getAuthenticators(factorsAllowed)
            .start(object : Callback<List<Authenticator>, MfaListAuthenticatorsException> {
                override fun onFailure(exception: MfaListAuthenticatorsException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMfaMap()
                    )
                }

                override fun onSuccess(res: List<Authenticator>) {
                    result.success(res.map { it.toMfaMap() })
                }
            })
    }
}
