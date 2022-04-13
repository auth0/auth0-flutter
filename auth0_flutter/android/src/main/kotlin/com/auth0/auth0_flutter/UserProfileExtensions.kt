package com.auth0.auth0_flutter

import com.auth0.android.result.UserProfile

fun UserProfile.toMap(): Map<String, Any?> {
    return mapOf(
        "id" to this.getId(),
        "name" to this.name,
        "givenName" to this.givenName,
        "familyName" to this.familyName,
        "middleName" to this.middleName,
        "nickname" to this.nickname,
        "preferredUsername" to this.preferredUsername,
        "profileURL" to this.profileURL,
        "pictureURL" to this.pictureURL,
        "websiteURL" to this.websiteURL,
        "email" to this.email,
        "isEmailVerified" to this.isEmailVerified,
        "gender" to this.gender,
        "birthdate" to this.birthdate,
        "zoneinfo" to this.zoneinfo,
        "locale" to this.locale,
        "phoneNumber" to this.phoneNumber,
        "isPhoneNumberVerified" to this.isPhoneNumberVerified,
        "address" to this.address,
        "updatedAt" to this.updatedAt,
        "customClaims" to this.customClaims,
    )
}

var publicClaims = listOf(
    "sub",
    "middle_name",
    "preferred_username",
    "profile",
    "website",
    "gender",
    "birthdate",
    "zoneinfo",
    "locale",
    "phone_number",
    "phone_number_verified",
    "updated_at",
    "address"
);

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

val UserProfile.customClaims: Map<String, Any>?
    get() = getExtraInfo().entries.filter { entry -> !publicClaims.contains(entry.key) }
        .associate { it.key to it.value }
