package com.auth0.auth0_flutter.utils

import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.CoreMatchers.not
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.util.*

@RunWith(RobolectricTestRunner::class)
class GetCustomClaimsTest {
    @Test
    fun `should return an empty map when no claims`() {
        val customClaims = getCustomClaims(mapOf());

        assertThat(customClaims, equalTo(mapOf()));
    }

    @Test
    fun `should remove filtered claims`() {
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

        val claims = claimsToFilter.associateWith { "test-value" }

        claimsToFilter.forEach {
            assertThat(claims[it], not(nullValue()));
        }

        val customClaims = getCustomClaims(claims);

        claimsToFilter.forEach {
            assertThat(customClaims[it], nullValue());
        }
    }

    @Test
    fun `should remove public claims`() {
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

        val claims = standardClaims.associateWith { "test-value" }

        standardClaims.forEach {
            assertThat(claims[it], not(nullValue()));
        }

        val customClaims = getCustomClaims(claims);

        standardClaims.forEach {
            assertThat(customClaims[it], nullValue());
        }
    }

    @Test
    fun `should return an empty map when no custom claims`() {
        val customClaims = getCustomClaims(mapOf("name" to "test", "given_name" to "test2"));

        assertThat(customClaims, equalTo(mapOf()));
    }

    @Test
    fun `should return custom claims`() {
        val customClaims = getCustomClaims(
            mapOf(
                "name" to "test-name",
                "given_name" to "test-given_name",
                "aud" to "test-aud",
                "custom" to "custom value"
            )
        );

        assertThat(customClaims, equalTo(mapOf("custom" to "custom value")));
    }
}
