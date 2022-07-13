package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class HasValidCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#hasValidCredentials";

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val minTtl = request.data.get("minTtl") as Int? ?: 0;

        result.success(credentialsManager.hasValidCredentials(minTtl.toLong()));
    }

}
