package com.auth0.auth0_flutter.utils

private val claimsToFilter = setOf(
    "aud",
    "iss",
    "iat",
    "exp",
    "nbf",
    "nonce",
    "azp",
    "auth_time",
    "s_hash",
    "at_hash",
    "c_hash"
)

val standardClaims = setOf(
    "sub",
    "name",
    "given_name",
    "family_name",
    "middle_name",
    "nickname",
    "preferred_username",
    "profile",
    "picture",
    "website",
    "email",
    "email_verified",
    "gender",
    "birthdate",
    "zoneinfo",
    "locale",
    "phone_number",
    "phone_number_verified",
    "address",
    "updated_at"
)

fun getCustomClaims(claims: Map<String, Any>): Map<String, Any> {
    val filteredClaims = claims.filterNot { claimsToFilter.contains(it.key) }

    return filteredClaims.filterNot {
        standardClaims.contains(it.key)
    }
}
