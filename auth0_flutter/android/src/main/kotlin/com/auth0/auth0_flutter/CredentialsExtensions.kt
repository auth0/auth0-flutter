package com.auth0.auth0_flutter

import com.auth0.android.result.Credentials

/**
 * Serializes [Credentials] into the map shape expected by the Dart
 * `Credentials.fromMap` factory.
 */
fun Credentials.toMap(): Map<String, Any?> {
    val scopes = this.scope?.split(" ") ?: listOf()
    val formattedDate = this.expiresAt.toInstant().toString()

    return buildMap {
        put("accessToken", accessToken)
        put("idToken", idToken)
        put("refreshToken", refreshToken)
        put("userProfile", user.toMap())
        put("expiresAt", formattedDate)
        put("scopes", scopes)
        put("tokenType", type)
        // IPSIE session_expiry ceiling, pinned at login and enforced by the
        // native SecureCredentialsManager; omitted when there is no ceiling.
        sessionExpiresAt?.let {
            put("sessionExpiry", java.util.Date(it * 1000L).toInstant().toString())
        }
    }
}
