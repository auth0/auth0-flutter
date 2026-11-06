package com.auth0.auth0_flutter

import com.auth0.android.result.AuthenticationMethod
import com.auth0.android.result.EmailAuthenticationMethod
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.android.result.MfaAuthenticationMethod
import com.auth0.android.result.MfaEnrollmentChallenge
import com.auth0.android.result.MyAccountProfile
import com.auth0.android.result.PasskeyAuthenticationMethod
import com.auth0.android.result.PasskeyEnrollmentChallenge
import com.auth0.android.result.PhoneAuthenticationMethod
import com.auth0.android.result.PushNotificationAuthenticationMethod
import com.auth0.android.result.RecoveryCodeEnrollmentChallenge
import com.auth0.android.result.TotpAuthenticationMethod
import com.auth0.android.result.TotpEnrollmentChallenge
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

fun AuthenticationMethod.toMyAccountMethodMap(): Map<String, Any?> {
    return buildMap {
        put("id", id)
        put("type", type)
        put("created_at", createdAt)
        when (val method = this@toMyAccountMethodMap) {
            is PhoneAuthenticationMethod -> {
                put("name", method.name)
                put("phone_number", method.phoneNumber)
                put("preferred_authentication_method",
                    method.preferredAuthenticationMethod)
            }
            is EmailAuthenticationMethod -> {
                put("name", method.name)
                put("email", method.email)
            }
            is TotpAuthenticationMethod -> {
                put("name", method.name)
            }
            is PushNotificationAuthenticationMethod -> {
                put("name", method.name)
            }
            else -> {
                put("name", null)
            }
        }
        put("usage", usage)
        if (this@toMyAccountMethodMap is MfaAuthenticationMethod) {
            put("confirmed", confirmed)
        }
    }
}

fun PasskeyAuthenticationMethod.toMyAccountPasskeyMethodMap(): Map<String, Any?> {
    return buildMap {
        put("id", id)
        put("type", type)
        put("created_at", createdAt)
        put("usage", usage)
        put("identity_user_id", identityUserId)
        put("user_agent", userAgent)
        put("key_id", keyId)
        put("public_key", publicKey)
        put("user_handle", userHandle)
        put("credential_device_type", credentialDeviceType)
        put("credential_backed_up", credentialBackedUp)
        put("transports", transports)
        put("aaguid", aaguid)
        put("relying_party_id", relyingPartyId)
    }
}

fun PasskeyEnrollmentChallenge.toMyAccountPasskeyChallengeMap(): Map<String, Any?> {
    val gson = Gson()
    // AuthnParamsPublicKey is a typed data class; convert via JSON tree to avoid
    // a toJson()/fromJson(String) round-trip through an intermediate String.
    val authParamsPublicKeyMap: Map<String, Any> = gson.fromJson(
        gson.toJsonTree(authParamsPublicKey),
        object : TypeToken<Map<String, Any>>() {}.type
    )
    return buildMap {
        put("authenticationMethodId", authenticationMethodId)
        put("authSession", authSession)
        put("authParamsPublicKey", authParamsPublicKeyMap)
    }
}

fun EnrollmentChallenge.toMyAccountChallengeMap(): Map<String, Any?> {
    return buildMap {
        put("id", id)
        put("auth_session", authSession)
        when (val challenge = this@toMyAccountChallengeMap) {
            is TotpEnrollmentChallenge -> {
                put("barcode_uri", challenge.barcodeUri)
                put("totp_secret", challenge.manualInputCode)
                put("totp_uri", challenge.barcodeUri)
            }
            is RecoveryCodeEnrollmentChallenge -> {
                put("recovery_code", challenge.recoveryCode)
            }
            is MfaEnrollmentChallenge -> {}
            else -> {}
        }
    }
}

fun MyAccountProfile.toMyAccountProfileMap(): Map<String, Any?> {
    return buildMap {
        put("user_id", userId)
        put("given_name", givenName)
        put("family_name", familyName)
        put("name", name)
        put("nickname", nickname)
        put("picture", picture)
        put("email", email)
        put("email_verified", emailVerified)
        put("phone_number", phoneNumber)
        put("phone_verified", phoneVerified)
        put("username", username)
        put("created_at", createdAt)
        put("updated_at", updatedAt)
        // Auth0.Android returns an empty map when `profile_policy` is not part
        // of the response; send null instead, as on iOS and the web.
        put("profile_policy", profilePolicy.takeIf { it.isNotEmpty() }?.mapValues {
            mapOf(
                "access" to it.value.access?.value,
                "source" to it.value.source?.value,
                "reason" to it.value.reason
            )
        })
    }
}
