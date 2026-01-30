package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel


class GetIdTokenContentRequestHandler: CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#getUserInfo"
    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val userProfile = credentialsManager.userProfile
        if (userProfile != null) {
            result.success(userProfile.toMap())
        } else {
            result.success(null)
        }
    }
}
