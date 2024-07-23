package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.util.*


class SaveCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#saveCredentials"

    override fun handle(
        credentialsManager: SecureCredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("credentials"), request.data)

        val credentials = request.data.get("credentials") as HashMap<*, *>

        assertHasProperties(listOf("accessToken", "idToken" , "tokenType", "expiresAt"), credentials, "credentials")

        var scope: String? = null
        val scopes = (credentials["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ")
        }

        println("SaveCredentialsRequestHandler::get " + credentials.get("expiresAt"))

        val instant = Instant.parse(credentials.get("expiresAt") as String)

        println("SaveCredentialsRequestHandler Instant::parse " + instant)

        credentialsManager.saveCredentials(Credentials(
            credentials.get("idToken") as String,
            credentials.get("accessToken") as String,
            credentials.get("tokenType") as String,
            credentials.get("refreshToken") as String?,
            Date.from(instant),
            scope,
        ))
        result.success(true)
    }
}
