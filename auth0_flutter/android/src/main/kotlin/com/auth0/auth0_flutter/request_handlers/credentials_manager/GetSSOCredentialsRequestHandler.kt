package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.SSOCredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class GetSSOCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getSSOCredentials"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val parameters = request.data["parameters"] as Map<String, String>? ?: mapOf()

        credentialsManager.getSsoCredentials(parameters, object :
            Callback<SSOCredentials, CredentialsManagerException> {
            override fun onFailure(exception: CredentialsManagerException) {
                result.error(exception.message ?: "UNKNOWN ERROR", exception.message, exception)
            }

            override fun onSuccess(credentials: SSOCredentials) {
                val map = mutableMapOf<String, Any?>(
                    "sessionTransferToken" to credentials.sessionTransferToken,
                    "tokenType" to credentials.tokenType,
                    "expiresIn" to credentials.expiresIn,
                    "idToken" to credentials.idToken
                )
                credentials.refreshToken?.let { map["refreshToken"] = it }
                result.success(map)
            }
        })
    }
}
