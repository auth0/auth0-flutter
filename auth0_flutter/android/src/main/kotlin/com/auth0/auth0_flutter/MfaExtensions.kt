package com.auth0.auth0_flutter

import com.auth0.android.authentication.mfa.MfaException
import com.auth0.android.result.Authenticator
import com.auth0.android.result.Challenge
import com.auth0.android.result.Credentials
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.android.result.MfaEnrollmentChallenge
import com.auth0.android.result.OobEnrollmentChallenge
import com.auth0.android.result.RecoveryCodeEnrollmentChallenge
import com.auth0.android.result.TotpEnrollmentChallenge

fun Authenticator.toMfaMap(): Map<String, Any?> = buildMap {
    put("id", id)
    put("type", type)
    put("authenticator_type", authenticatorType)
    put("active", active)
    put("oob_channel", oobChannel)
    put("name", name)
}

fun Challenge.toMfaChallengeMap(): Map<String, Any?> = buildMap {
    put("challenge_type", challengeType)
    put("oob_code", oobCode)
    put("binding_method", bindingMethod)
}

fun EnrollmentChallenge.toMfaEnrollmentMap(): Map<String, Any?> = buildMap {
    put("id", id)
    put("auth_session", authSession)
    put("oob_code", oobCode)
    when (val challenge = this@toMfaEnrollmentMap) {
        is TotpEnrollmentChallenge -> {
            put("authenticator_type", "otp")
            put("totp_secret", challenge.manualInputCode)
            put("barcode_uri", challenge.barcodeUri)
        }
        is OobEnrollmentChallenge -> {
            put("authenticator_type", "oob")
            put("binding_method", challenge.bindingMethod)
        }
        is RecoveryCodeEnrollmentChallenge -> {
            put("authenticator_type", "recovery-code")
            put("recovery_codes", listOf(challenge.recoveryCode))
        }
        is MfaEnrollmentChallenge -> {}
        else -> {}
    }
}

fun Credentials.toMfaCredentialsMap(): Map<String, Any?> {
    val scopes = scope?.split(" ") ?: listOf()
    val formattedDate = expiresAt.toInstant().toString()
    return mapOf(
        "accessToken" to accessToken,
        "idToken" to idToken,
        "refreshToken" to refreshToken,
        "userProfile" to user.toMap(),
        "expiresAt" to formattedDate,
        "scopes" to scopes,
        "tokenType" to type
    )
}

fun MfaException.toMfaMap(): Map<String, Any> = buildMap {
    // `code` and `description` carry the actual error from the native MFA
    // SDK; surface them in the details map (in addition to the top-level
    // result.error code/message) so the Dart layer always has them.
    put("code", getCode())
    put("description", getDescription())
    put("_statusCode", statusCode)
    put(
        "_errorFlags", mapOf(
            "isNetworkError" to (getCode() == "network_error")
        )
    )
}
