package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

class HasValidCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#hasValidCredentials";

    override fun handle(
        credentialsManager: CredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        var hasValidCredentials: Boolean;
        if (request.data.getOrDefault("minTtil", null) is Long) {
            hasValidCredentials = credentialsManager.hasValidCredentials(request.data.get("minTtl") as Long);
        } else {
            hasValidCredentials = credentialsManager.hasValidCredentials();
        }
        result.success(hasValidCredentials);
    }
}
