package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

private const val AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"

class RenewAccessTokenApiRequestHandler : ApiRequestHandler {
    override val method: String = AUTH_RENEWACCESSTOKEN_METHOD

    override fun handle(api: AuthenticationAPIClient, request: MethodCallRequest, result: MethodChannel.Result) {
        val args = request.data;

        api.renewAuth(args["refreshToken"] as String).start(object :
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
                
                result.success(
                    mapOf(
                        "accessToken" to credentials.accessToken,
                        "idToken" to credentials.idToken,
                        "refreshToken" to credentials.refreshToken,
                        "userProfile" to mapOf<String, String>(),
                        "expiresAt" to formattedDate,
                        "scopes" to scope
                    )
                )
            }
        });
    }
}
