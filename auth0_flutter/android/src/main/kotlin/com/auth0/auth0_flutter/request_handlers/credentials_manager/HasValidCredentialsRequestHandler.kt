package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class HasValidCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#hasValidCredentials";

    override fun handle(
        credentialsManager: CredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        var minTtl: Long? = null;

        if (request.data.getOrDefault("minTtl", null) is Long) {
            minTtl = request.data["minTtl"] as Long;
        }

        result.success(hasValidCredentials(credentialsManager, minTtl));
    }

    private fun hasValidCredentials(credentialsManager: CredentialsManager, minTtl: Long?): Boolean {
        return if (minTtl != null) {
            credentialsManager.hasValidCredentials(minTtl);
        } else {
            credentialsManager.hasValidCredentials();
        }
    }
}
