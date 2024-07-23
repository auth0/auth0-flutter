package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val AUTH_RENEW_METHOD = "auth#renew"

class RenewApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_RENEW_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("refreshToken"), request.data)

        val renewAuthBuilder = api.renewAuth(request.data["refreshToken"] as String)

        val scopes = (request.data["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            renewAuthBuilder.addParameter("scope", scopes.joinToString(separator = " "))
        }

        if (request.data["parameters"] is HashMap<*, *>) {
            renewAuthBuilder.addParameters(request.data["parameters"] as Map<String, String>)
        }

        renewAuthBuilder.start(object :
            Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(credentials: Credentials) {
                println("RenewApiRequestHandler::onSuccess credentials.expiresAt ${credentials.expiresAt}");
                val scope = credentials.scope?.split(" ") ?: listOf()
                val formattedDate = credentials.expiresAt.toInstant().toString();

                println("RenewApiRequestHandler::onSuccess formattedDate ${formattedDate}");

                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to credentials.user.toMap(),
                        "expiresAt" to formattedDate,
                        "scopes" to scope,
                        "tokenType" to credentials.type
                    )
                )
            }
        })
    }
}
