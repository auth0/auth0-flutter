package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.JwtTestUtils
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyMap
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*

@RunWith(RobolectricTestRunner::class)
class GetCredentialsRequestHandlerTest {

    @Test
    fun `should call getCredentials without providing options`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            isNull(),
            eq(0),
            anyMap(),
            any()
        )
    }

    @Test
    fun `should use default value for minTtl and parameters when only providing scope`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "scopes" to arrayListOf("test-scope1", "test-scope2"),
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            eq("test-scope1 test-scope2"),
            eq(0),
            anyMap(),
            any()
        )
    }

    @Test
    fun `should use default value for parameters when only providing minTtl`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "minTtl" to 30,
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            isNull(),
            eq(30),
            anyMap(),
            any()
        )
    }

    @Test
    fun `should use default value for minTtl when only providing parameters`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            isNull(),
            eq(0),
            eq(mapOf("test" to "test-value", "test2" to "test-value")),
            any()
        )
    }

    @Test
    fun `should use default value for parameters when providing scope and minTtl`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "minTtl" to 30,
            "scopes" to arrayListOf("test-scope1", "test-scope2"),
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            eq("test-scope1 test-scope2"),
            eq(30),
            anyMap(),
            any()
        )
    }

    @Test
    fun `should use default value for minTtl when only providing scope and parameters`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "scopes" to arrayListOf("test-scope1", "test-scope2"),
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            eq("test-scope1 test-scope2"),
            eq(0),
            eq(mapOf("test" to "test-value", "test2" to "test-value")),
            any()
        )
    }

    @Test
    fun `should call getCredentials when providing minTtl and parameters`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "minTtl" to 30,
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            isNull(),
            eq(30),
            eq(mapOf("test" to "test-value", "test2" to "test-value")),
            any()
        )
    }

    @Test
    fun `should call getCredentials when providing all options`() {
        val handler = GetCredentialsRequestHandler()
        val options = hashMapOf(
            "minTtl" to 30,
            "scopes" to arrayListOf("test-scope1", "test-scope2"),
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).getCredentials(
            eq("test-scope1 test-scope2"),
            eq(30),
            eq(mapOf("test" to "test-value", "test2" to "test-value")),
            any()
        )
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>()
        val handler = GetCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()

        `when`(exception.message).thenReturn("test-message")

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(3)
            ob.onFailure(exception)
        }.`when`(mockCredentialsManager).getCredentials(isNull(), anyInt(), anyMap(), any())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).error(eq("test-message"), eq("test-message"), any())
    }

    @Test
    fun `should fallback to UNKNOWN ERROR on failure without a message`() {
        val options = hashMapOf<String, Any>()
        val handler = GetCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()

        `when`(exception.message).thenReturn(null)

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(3)
            ob.onFailure(exception)
        }.`when`(mockCredentialsManager).getCredentials(isNull(), anyInt(), anyMap(), any())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).error(eq("UNKNOWN ERROR"), isNull(), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf<String, Any>()
        val handler = GetCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "test", "", null, Date(), "scope1 scope2")

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(3)
            ob.onSuccess(credentials)
        }.`when`(mockCredentialsManager).getCredentials(isNull(), anyInt(), anyMap(), any())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val sdf =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US)

        val formattedDate = sdf.format(credentials.expiresAt)

        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["accessToken"],
            CoreMatchers.equalTo(credentials.accessToken)
        )
        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["idToken"],
            CoreMatchers.equalTo(credentials.idToken)
        )
        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["refreshToken"],
            CoreMatchers.equalTo(credentials.refreshToken)
        )
        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["expiresAt"] as String,
            CoreMatchers.equalTo(formattedDate)
        )
        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["scopes"],
            CoreMatchers.equalTo(listOf("scope1", "scope2"))
        )
        MatcherAssert.assertThat(
            ((captor.firstValue as Map<*, *>)["userProfile"] as Map<*, *>)["name"],
            CoreMatchers.equalTo("John Doe")
        )
    }

    @Test
    fun `should call result success on success without scopes`() {
        val options = hashMapOf<String, Any>()
        val handler = GetCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "test", "", null, Date(), scope = null)

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(3)
            ob.onSuccess(credentials)
        }.`when`(mockCredentialsManager).getCredentials(isNull(), anyInt(), anyMap(), any())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        val captor = argumentCaptor<() -> Map<String, *>>()

        verify(mockResult).success(captor.capture())

        MatcherAssert.assertThat(
            (captor.firstValue as Map<*, *>)["scopes"],
            CoreMatchers.equalTo(listOf<String>())
        )
    }

}
