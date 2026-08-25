package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class ClearAllRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#clearAll"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        try {
            credentialsManager.clearAll()
            result.success(null)
        } catch (exception: Exception) {
            result.error(exception.message ?: "UNKNOWN ERROR", exception.message, null)
        }
    }
}
