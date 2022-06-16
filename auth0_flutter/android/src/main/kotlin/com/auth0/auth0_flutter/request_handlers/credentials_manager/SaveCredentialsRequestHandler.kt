package com.auth0.auth0_flutter.request_handlers.credentials_manager

import android.content.Context
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAccessor
import java.util.*


class SaveCredentialsRequestHandler : CredentialsManagerRequestHandler {
    override val method: String = "credentialsManager#saveCredentials";

    override fun handle(
        credentialsManager: CredentialsManager,
        context: Context,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val credentials = request.data.get("credentials") as HashMap<*, *>;
        val scope = credentials.getOrDefault("scopes", null) as ArrayList<*>?
        val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.getDefault());
        var date = format.parse(credentials.get("expiresAt") as String);

        credentialsManager.saveCredentials(Credentials(
            credentials.get("idToken") as String,
            credentials.get("accessToken") as String,
            credentials.get("type") as String,
            credentials.get("refreshToken") as String?,
            date,
            scope?.joinToString { " " },
        ));
        result.success(null);
    }
}
