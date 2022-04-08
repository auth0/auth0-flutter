package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.jwt.JWT
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import com.auth0.auth0_flutter.utils.processClaims
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

private const val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"

class RenewAccessTokenApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_RENEWACCESSTOKEN_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        assertHasProperties(listOf("refreshToken"), request.data);

        var renewAuthBuilder = api.renewAuth(request.data["refreshToken"] as String);

        val scopes = request.data.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            renewAuthBuilder.addParameter("scope", scopes.joinToString(separator = " "))
        }

        renewAuthBuilder.start(object :
            Callback<Credentials, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                );
            }

            override fun onSuccess(credentials: Credentials) {
                val scope = credentials.scope?.split(" ") ?: listOf()
                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)
                val jwt = JWT(credentials.idToken)

                // Map all claim values to their underlying type as Any
                val claims = processClaims(jwt.claims.mapValues { it.value.asObject(Any::class.java) })

                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to claims,
                        "expiresAt" to formattedDate,
                        "scopes" to scope
                    )
                )
            }
        });
    }
}
