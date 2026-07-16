package com.auth0.auth0_flutter

import com.auth0.android.result.ActorClaim
import com.auth0.android.result.UserProfile

import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class UserProfileExtensionsTest {
    @Test
    fun `should return the properties as a map when calling toMap`() {
        val user = UserProfile(
            "",
            "test-name",
            "test-nickname",
            "http://test-picture.com",
            "test-email",
            true,
            "test-family_name",
            null,
            null,
            mapOf(
                "sub" to "test-sub",
                "middle_name" to "test-middle_name",
            ),
            null,
            null,
            "test-given_name"
        )
        val map = user.toMap()

        assertThat(map["name"], equalTo("test-name"))
        assertThat(map["sub"], equalTo("test-sub"))
        assertThat(map["middle_name"], equalTo("test-middle_name"))
        assertThat(map["nickname"], equalTo("test-nickname"))
        assertThat(map["picture"], equalTo("http://test-picture.com"))
        assertThat(map["email"], equalTo("test-email"))
        assertThat(map["email_verified"], equalTo(true))
        assertThat(map["family_name"], equalTo("test-family_name"))
        assertThat(map["given_name"], equalTo("test-given_name"))
    }

    @Test
    fun `should return the custom_claims when calling toMap`() {
        val user = UserProfile(
            "",
            "test-name",
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            mapOf("sub" to "test-sub", "test" to "test-claim"),
            null,
            null,
            null
        )
        val map = user.toMap()

        assertThat((map["custom_claims"] as Map<*, *>)["test"], equalTo("test-claim"))
    }

    @Test
    fun `should return null for picture when it is a non-string value`() {
        val user = UserProfile(
            "",
            null, null, null, null, null, null, null, null,
            mapOf("sub" to "test-sub", "picture" to mapOf("url" to "http://test.com")),
            null, null, null
        )
        assertThat(user.toMap()["picture"], equalTo(null))
    }

    @Test
    fun `should return null for string claims when they are non-string values`() {
        val user = UserProfile(
            "",
            null, null, null, null, null, null, null, null,
            mapOf(
                "sub" to "test-sub",
                "middle_name" to mapOf("value" to "test"),
                "preferred_username" to mapOf("value" to "test"),
                "profile" to mapOf("value" to "test"),
                "website" to mapOf("value" to "test"),
                "gender" to mapOf("value" to "test"),
                "birthdate" to mapOf("value" to "test"),
                "zoneinfo" to mapOf("value" to "test"),
                "locale" to mapOf("value" to "test"),
                "phone_number" to mapOf("value" to "test"),
                "updated_at" to mapOf("value" to "test"),
            ),
            null, null, null
        )

        assertThat(user.middleName, equalTo(null))
        assertThat(user.preferredUsername, equalTo(null))
        assertThat(user.profileURL, equalTo(null))
        assertThat(user.websiteURL, equalTo(null))
        assertThat(user.gender, equalTo(null))
        assertThat(user.birthdate, equalTo(null))
        assertThat(user.zoneinfo, equalTo(null))
        assertThat(user.locale, equalTo(null))
        assertThat(user.phoneNumber, equalTo(null))
        assertThat(user.updatedAt, equalTo(null))
    }

    @Test
    fun `should configure the extension properties`() {
        val user = UserProfile(
            "",
            "John Doe",
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            mapOf(
                "sub" to "test-sub",
                "middle_name" to "test-middle_name",
                "preferred_username" to "test-preferred_username",
                "profile" to "https://test-profile.com",
                "website" to "https://test-website.com",
                "gender" to "test-gender",
                "birthdate" to "test-birthdate",
                "zoneinfo" to "test-zoneinfo",
                "locale" to "test-locale",
                "phone_number" to "test-phone_number",
                "phone_number_verified" to true,
                "updated_at" to "2022-04-22",
                "address" to mapOf("street" to "test-street")
            ),
            null,
            null,
            null
        )

        assertThat(user.sub, equalTo("test-sub"))
        assertThat(user.middleName, equalTo("test-middle_name"))
        assertThat(user.preferredUsername, equalTo("test-preferred_username"))
        assertThat(user.profileURL, equalTo("https://test-profile.com"))
        assertThat(user.websiteURL, equalTo("https://test-website.com"))
        assertThat(user.gender, equalTo("test-gender"))
        assertThat(user.birthdate, equalTo("test-birthdate"))
        assertThat(user.zoneinfo, equalTo("test-zoneinfo"))
        assertThat(user.locale, equalTo("test-locale"))
        assertThat(user.phoneNumber, equalTo("test-phone_number"))
        assertThat(user.isPhoneNumberVerified, equalTo(true))
        assertThat(user.updatedAt, equalTo("2022-04-22"))
        assertThat(user.address?.get("street"), equalTo("test-street"))
    }

    @Test
    fun `should map the actor claim including nested chain when calling toMap`() {
        val nestedActor = ActorClaim(
            sub = "original-actor-456",
            extraProperties = mapOf("role" to "admin")
        )
        val actor = ActorClaim(
            sub = "actor-agent-123",
            actor = nestedActor,
            extraProperties = mapOf("org" to "auth0")
        )
        val user = UserProfile(
            "",
            "test-name",
            null, null, null, null, null, null, null,
            mapOf("sub" to "test-sub"),
            null, null, null,
            actor
        )

        val act = user.toMap()["act"] as Map<*, *>
        assertThat(act["sub"], equalTo("actor-agent-123"))
        assertThat(act["org"], equalTo("auth0"))

        val nested = act["act"] as Map<*, *>
        assertThat(nested["sub"], equalTo("original-actor-456"))
        assertThat(nested["role"], equalTo("admin"))
    }

    @Test
    fun `should map null act when the actor claim is absent`() {
        val user = UserProfile(
            "",
            "test-name",
            null, null, null, null, null, null, null,
            mapOf("sub" to "test-sub"),
            null, null, null
        )

        assertThat(user.toMap()["act"], nullValue())
    }
}
