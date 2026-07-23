package com.auth0.auth0_flutter

import com.auth0.android.result.Credentials

/**
 * Serializes [Credentials] into the map shape expected by the Dart
 * `Credentials.fromMap` factory.
 *
 * The IPSIE `session_expiry` claim is an absolute Unix-seconds ceiling asserted
 * by the upstream IdP. It is surfaced to the Dart layer as an ISO-8601 string
 * (`sessionExpiry`) so app code can read `credentials.sessionExpiry`; the
 * enforcement itself is performed by the native `SecureCredentialsManager`.
 * When the claim is absent the key is omitted (meaning "no ceiling").
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
        sessionExpiryIso()?.let { put("sessionExpiry", it) }
    }
}

/**
 * Reads the `session_expiry` claim from the decoded ID token (exposed via the
 * user profile's extra info) and converts the Unix-seconds value to an ISO-8601
 * UTC string. Returns `null` when the claim is absent or not numeric.
 */
private fun Credentials.sessionExpiryIso(): String? {
    val claim = user.getExtraInfo()["session_expiry"] as? Number ?: return null
    return java.time.Instant.ofEpochSecond(claim.toLong()).toString()
}
