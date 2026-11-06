package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.request.GetUserProfileOptions
import com.auth0.android.request.Request
import com.auth0.android.result.MyAccountProfile
import com.auth0.android.result.ProfileFieldAccess
import com.auth0.android.result.ProfileFieldPolicy
import com.auth0.android.result.ProfileFieldSource
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GetUserProfileRequestHandlerTest {

    private fun handle(
        options: HashMap<String, Any>,
        configure: (Request<MyAccountProfile, MyAccountException>) -> Unit = {}
    ): Pair<MyAccountAPIClient, Result> {
        val handler = GetUserProfileRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<MyAccountProfile, MyAccountException>>()
        val request = MethodCallRequest(account = mock<Auth0>(), options)

        whenever(mockClient.getUserProfile(any())).thenReturn(mockRequest)
        configure(mockRequest)

        handler.handle(mockClient, request, mockResult)
        return Pair(mockClient, mockResult)
    }

    private fun Request<MyAccountProfile, MyAccountException>.succeedWith(
        profile: MyAccountProfile
    ) {
        doAnswer {
            it.getArgument<Callback<MyAccountProfile, MyAccountException>>(0)
                .onSuccess(profile)
        }.whenever(this).start(any())
    }

    @Test
    fun `should call getUserProfile with default options`() {
        val (client, _) = handle(hashMapOf())

        verify(client).getUserProfile(eq(GetUserProfileOptions(emptyList(), true)))
    }

    @Test
    fun `should call getUserProfile with fields and includeFields`() {
        val (client, _) = handle(
            hashMapOf(
                "fields" to listOf("given_name", "profile_policy"),
                "includeFields" to false
            )
        )

        verify(client).getUserProfile(
            eq(GetUserProfileOptions(listOf("given_name", "profile_policy"), false))
        )
    }

    @Test
    fun `should ignore non-string fields`() {
        val (client, _) = handle(
            hashMapOf("fields" to listOf("given_name", 42, null))
        )

        verify(client).getUserProfile(eq(GetUserProfileOptions(listOf("given_name"), true)))
    }

    @Test
    fun `should call result success with the mapped profile`() {
        val profile = MyAccountProfile(
            userId = "auth0|123",
            givenName = "Jane",
            email = "jane@example.com",
            emailVerified = true,
            phoneVerified = false,
            createdAt = "2024-01-01T00:00:00.000Z",
            profilePolicy = mapOf(
                "/given_name" to ProfileFieldPolicy(
                    ProfileFieldAccess.READ_ONLY,
                    ProfileFieldSource.IDP,
                    "managed_by_identity_provider"
                ),
                "/nickname" to ProfileFieldPolicy(null, null, null)
            )
        )
        val (_, result) = handle(hashMapOf()) { it.succeedWith(profile) }

        val captor = argumentCaptor<Map<String, Any?>>()
        verify(result).success(captor.capture())
        val map = captor.firstValue
        assertThat(map["user_id"], equalTo("auth0|123"))
        assertThat(map["given_name"], equalTo("Jane"))
        assertThat(map["email"], equalTo("jane@example.com"))
        assertThat(map["email_verified"], equalTo(true))
        assertThat(map["phone_verified"], equalTo(false))
        assertThat(map["created_at"], equalTo("2024-01-01T00:00:00.000Z"))
        assertThat(map["family_name"], nullValue())

        @Suppress("UNCHECKED_CAST")
        val policy = map["profile_policy"] as Map<String, Map<String, Any?>>
        assertThat(policy["/given_name"]!!["access"], equalTo("read_only"))
        assertThat(policy["/given_name"]!!["source"], equalTo("idp"))
        assertThat(policy["/given_name"]!!["reason"], equalTo("managed_by_identity_provider"))
        assertThat(policy["/nickname"]!!["access"], nullValue())
        assertThat(policy["/nickname"]!!["source"], nullValue())
    }

    @Test
    fun `should send a null profile_policy when it is not part of the response`() {
        val (_, result) = handle(hashMapOf()) {
            it.succeedWith(MyAccountProfile(givenName = "Jane"))
        }

        val captor = argumentCaptor<Map<String, Any?>>()
        verify(result).success(captor.capture())
        assertThat(captor.firstValue.containsKey("profile_policy"), equalTo(true))
        assertThat(captor.firstValue["profile_policy"], nullValue())
    }

    @Test
    fun `should call result error with validation errors on failure`() {
        val exception = mock<MyAccountException>()
        whenever(exception.getCode()).thenReturn("invalid_request")
        whenever(exception.getDescription()).thenReturn("Invalid query")
        whenever(exception.statusCode).thenReturn(400)
        whenever(exception.isNetworkError).thenReturn(false)
        whenever(exception.validationErrors).thenReturn(
            listOf(
                MyAccountException.ValidationError(
                    "unknown field", "fields", null, "query"
                )
            )
        )

        val (_, result) = handle(hashMapOf()) { request ->
            doAnswer {
                it.getArgument<Callback<MyAccountProfile, MyAccountException>>(0)
                    .onFailure(exception)
            }.whenever(request).start(any())
        }

        val captor = argumentCaptor<Map<String, Any>>()
        verify(result).error(eq("invalid_request"), eq("Invalid query"), captor.capture())
        assertThat(captor.firstValue["_statusCode"], equalTo(400))
        assertThat(
            captor.firstValue["validation_errors"],
            equalTo(
                listOf(
                    mapOf(
                        "detail" to "unknown field",
                        "field" to "fields",
                        "pointer" to null,
                        "source" to "query"
                    )
                )
            )
        )
    }

    @Test
    fun `should omit validation_errors when there are none`() {
        val exception = mock<MyAccountException>()
        whenever(exception.getCode()).thenReturn("insufficient_scope")
        whenever(exception.getDescription()).thenReturn("Insufficient scope")
        whenever(exception.statusCode).thenReturn(403)
        whenever(exception.isNetworkError).thenReturn(false)
        // Auth0.Android returns null when the response has no validation_errors.
        // An unstubbed mock would return an empty list instead.
        whenever(exception.validationErrors).thenReturn(null)

        val (_, result) = handle(hashMapOf()) { request ->
            doAnswer {
                it.getArgument<Callback<MyAccountProfile, MyAccountException>>(0)
                    .onFailure(exception)
            }.whenever(request).start(any())
        }

        val captor = argumentCaptor<Map<String, Any>>()
        verify(result).error(eq("insufficient_scope"), eq("Insufficient scope"), captor.capture())
        assertThat(captor.firstValue.containsKey("validation_errors"), equalTo(false))
    }
}
