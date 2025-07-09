package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.junit.Test
import com.auth0.auth0_flutter.JwtTestUtils
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyMap
import org.mockito.Mockito.`when`
import org.mockito.kotlin.any
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.doAnswer
import org.mockito.kotlin.eq
import org.mockito.kotlin.isNull
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@RunWith(RobolectricTestRunner::class)
class RenewCredentialsRequestHandlerTest {

    @Test
    fun `should call getCredentials without providing options`() {
        val handler = RenewCredentialsRequestHandler()
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
            eq(true),
            any()
        )
    }

    @Test
    fun `should use default value for scope and minTtl when only providing parameters`() {
        val handler = RenewCredentialsRequestHandler()
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
            eq(true),
            any()
        )
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>()
        val handler = RenewCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()

        `when`(exception.message).thenReturn("test-message")

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(4)
            ob.onFailure(exception)
        }.`when`(mockCredentialsManager)
            .getCredentials(isNull(), anyInt(), anyMap(), eq(true), any())

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
        val handler = RenewCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()

        `when`(exception.message).thenReturn(null)

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(4)
            ob.onFailure(exception)
        }.`when`(mockCredentialsManager)
            .getCredentials(isNull(), anyInt(), anyMap(), eq(true), any())

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
        val handler = RenewCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "accessToken", "Bearer", null, Date(), "scope1")

        doAnswer {
            val ob = it.getArgument<Callback<Credentials, CredentialsManagerException>>(4)
            ob.onSuccess(credentials)
        }.`when`(mockCredentialsManager)
            .getCredentials(isNull(), anyInt(), anyMap(), eq(true), any())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val sdf =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)

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
            CoreMatchers.equalTo(listOf("scope1"))
        )
        MatcherAssert.assertThat(
            ((captor.firstValue as Map<*, *>)["userProfile"] as Map<*, *>)["name"],
            CoreMatchers.equalTo("John Doe")
        )
    }
}
