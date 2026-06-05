package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class ClearApiCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#clearApiCredentials"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val audience = request.data["audience"] as? String
        if (audience.isNullOrBlank()) {
            result.error("UNKNOWN ERROR", "audience is required to clear API credentials", null)
            return
        }

        val scope = request.data["scope"] as? String

        // Stored API credentials are keyed by audience and (optional) scope.
        credentialsManager.clearApiCredentials(audience, scope)
        result.success(true)
    }
}
