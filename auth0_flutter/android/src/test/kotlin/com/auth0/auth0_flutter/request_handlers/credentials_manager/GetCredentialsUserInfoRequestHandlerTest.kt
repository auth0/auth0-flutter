package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.result.UserProfile
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.util.Date

@RunWith(RobolectricTestRunner::class)
class GetCredentialsUserInfoRequestHandlerTest {

    @Test
    fun `handles returns correct method`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        MatcherAssert.assertThat(
            handler.handles,
            CoreMatchers.`is`("credentialsManager#user")
        )
    }

    @Test
    fun `returns user profile map when credentials exist`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val userProfile = UserProfile(
            "auth0|123456",
            "John Doe",
            "john.doe@example.com",
            true,
            "John",
            "Doe",
            "johndoe",
            "https://example.com/picture.jpg",
            Date(),
            mapOf("role" to "admin")
        )

        `when`(mockCredentialsManager.userProfile).thenReturn(userProfile)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).success(userProfile.toMap())
    }

    @Test
    fun `returns null when no credentials stored`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        `when`(mockCredentialsManager.userProfile).thenReturn(null)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).success(null)
    }

    @Test
    fun `returns null when userProfile is null`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        `when`(mockCredentialsManager.userProfile).thenReturn(null)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).success(null)
    }

    @Test
    fun `converts all UserProfile fields correctly`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val updatedAt = Date()
        val userProfile = UserProfile(
            "auth0|123456",
            "John Doe",
            "john.doe@example.com",
            true,
            "John",
            "Doe",
            "johndoe",
            "https://example.com/picture.jpg",
            updatedAt,
            mapOf("role" to "admin", "department" to "engineering")
        )

        `when`(mockCredentialsManager.userProfile).thenReturn(userProfile)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        argumentCaptor<Map<String, Any?>>().apply {
            verify(mockResult).success(capture())

            val result = firstValue
            MatcherAssert.assertThat(result["sub"], CoreMatchers.`is`("auth0|123456"))
            MatcherAssert.assertThat(result["name"], CoreMatchers.`is`("John Doe"))
            MatcherAssert.assertThat(result["email"], CoreMatchers.`is`("john.doe@example.com"))
            MatcherAssert.assertThat(result["email_verified"], CoreMatchers.`is`(true))
            MatcherAssert.assertThat(result["given_name"], CoreMatchers.`is`("John"))
            MatcherAssert.assertThat(result["family_name"], CoreMatchers.`is`("Doe"))
            MatcherAssert.assertThat(result["nickname"], CoreMatchers.`is`("johndoe"))
            MatcherAssert.assertThat(result["picture"], CoreMatchers.`is`("https://example.com/picture.jpg"))
            MatcherAssert.assertThat(result["custom_claims"], CoreMatchers.notNullValue())

            @Suppress("UNCHECKED_CAST")
            val customClaims = result["custom_claims"] as Map<String, Any>
            MatcherAssert.assertThat(customClaims["role"], CoreMatchers.`is`("admin"))
            MatcherAssert.assertThat(customClaims["department"], CoreMatchers.`is`("engineering"))
        }
    }

    @Test
    fun `handles custom claims in UserProfile`() {
        val handler = GetCredentialsUserInfoRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val userProfile = UserProfile(
            "auth0|123456",
            "John Doe",
            null,
            false,
            null,
            null,
            null,
            null,
            null,
            mapOf(
                "custom_field_1" to "value1",
                "custom_field_2" to 123,
                "custom_field_3" to true
            )
        )

        `when`(mockCredentialsManager.userProfile).thenReturn(userProfile)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        argumentCaptor<Map<String, Any?>>().apply {
            verify(mockResult).success(capture())

            val result = firstValue
            MatcherAssert.assertThat(result["custom_claims"], CoreMatchers.notNullValue())

            @Suppress("UNCHECKED_CAST")
            val customClaims = result["custom_claims"] as Map<String, Any>
            MatcherAssert.assertThat(customClaims["custom_field_1"], CoreMatchers.`is`("value1"))
            MatcherAssert.assertThat(customClaims["custom_field_2"], CoreMatchers.`is`(123))
            MatcherAssert.assertThat(customClaims["custom_field_3"], CoreMatchers.`is`(true))
        }
    }
}
