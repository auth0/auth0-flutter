package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class ClearCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#clearCredentials";

    override fun handle(
        credentialsManager: CredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        credentialsManager.clearCredentials();
        result.success(null);
    }
}
