package com.auth0.auth0_flutter

import com.auth0.android.jwt.Claim
import com.auth0.android.result.UserProfile
import com.auth0.auth0_flutter.utils.getCustomClaims

fun UserProfile.toMap(): Map<String, Any?> {
    return mapOf(
        "sub" to this.sub,
        "name" to this.name,
        "given_name" to this.givenName,
        "family_name" to this.familyName,
        "middle_name" to this.middleName,
        "nickname" to this.nickname,
        "preferred_username" to this.preferredUsername,
        "profile" to this.profileURL,
        "picture" to this.pictureURL,
        "website" to this.websiteURL,
        "email" to this.email,
        "email_verified" to this.isEmailVerified,
        "gender" to this.gender,
        "birthdate" to this.birthdate,
        "zoneinfo" to this.zoneinfo,
        "locale" to this.locale,
        "phone_number" to this.phoneNumber,
        "phone_number_verified" to this.isPhoneNumberVerified,
        "address" to this.address,
        "updated_at" to this.updatedAt,
        "custom_claims" to this.customClaims,
    )
}

val UserProfile.sub: String
    get() = getExtraInfo()["sub"] as String

val UserProfile.middleName: String?
    get() = getExtraInfo()["middle_name"] as String?

val UserProfile.preferredUsername: String?
    get() = getExtraInfo()["preferred_username"] as String?

val UserProfile.profileURL: String?
    get() = getExtraInfo()["profile"] as String?

val UserProfile.websiteURL: String?
    get() = getExtraInfo()["website"] as String?

val UserProfile.gender: String?
    get() = getExtraInfo()["gender"] as String?

val UserProfile.birthdate: String?
    get() = getExtraInfo()["birthdate"] as String?

val UserProfile.zoneinfo: String?
    get() = getExtraInfo()["zoneinfo"] as String?

val UserProfile.locale: String?
    get() = getExtraInfo()["locale"] as String?

val UserProfile.phoneNumber: String?
    get() = getExtraInfo()["phone_number"] as String?

val UserProfile.isPhoneNumberVerified: Boolean?
    get() = getExtraInfo()["phone_number_verified"] as Boolean?

val UserProfile.updatedAt: String?
    get() = getExtraInfo()["updated_at"] as String?

val UserProfile.address: Map<String, String>?
    get() = getExtraInfo()["address"] as Map<String, String>?

val UserProfile.customClaims: Map<String, Any>
    get() = getCustomClaims(getExtraInfo())
