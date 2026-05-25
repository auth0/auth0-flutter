package com.auth0.auth0_flutter

import com.auth0.android.result.AuthenticationMethod
import com.auth0.android.result.EmailAuthenticationMethod
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.android.result.MfaAuthenticationMethod
import com.auth0.android.result.MfaEnrollmentChallenge
import com.auth0.android.result.PhoneAuthenticationMethod
import com.auth0.android.result.PushNotificationAuthenticationMethod
import com.auth0.android.result.RecoveryCodeEnrollmentChallenge
import com.auth0.android.result.TotpAuthenticationMethod
import com.auth0.android.result.TotpEnrollmentChallenge

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
            else -> {}
        }
        if (this@toMyAccountMethodMap is MfaAuthenticationMethod) {
            put("confirmed", confirmed)
        }
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
