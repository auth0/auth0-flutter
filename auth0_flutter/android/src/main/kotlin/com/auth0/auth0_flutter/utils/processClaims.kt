package com.auth0.auth0_flutter.utils

fun processClaims(claims: Map<String, Any?>) : Map<String, Any?> {
    val claimsToFilter = setOf(
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
        "phone_number",
        "phone_number_verified_boolean",
        "address",
        "updated_at"
    )

    // Remove the claims we don't want to appear in this map
    val filteredClaims = claims.filterNot { claimsToFilter.contains(it.key) }

    // Take anything that's not a standard claim and move it to "custom_claims" key
    return filteredClaims + mapOf("custom_claims" to filteredClaims.filterNot {
        standardClaims.contains(it.key)
    }).filterKeys { standardClaims.contains(it) || it == "custom_claims" }
}
