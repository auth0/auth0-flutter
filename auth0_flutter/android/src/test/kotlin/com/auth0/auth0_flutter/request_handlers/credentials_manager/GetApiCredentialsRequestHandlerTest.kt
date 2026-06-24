package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.APICredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyMap
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.util.Date

@RunWith(RobolectricTestRunner::class)
class GetApiCredentialsRequestHandlerTest {

    @Test
    fun `should call getApiCredentials with the provided audience and options`() {
        val handler = GetApiCredentialsRequestHandler()
        val options = hashMapOf(
            "audience" to "test-audience",
            "scopes" to arrayListOf("a", "b"),
            "minTtl" to 30,
            "parameters" to mapOf("p" to "1"),
            "headers" to mapOf("h" to "2")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockCredentialsManager).getApiCredentials(
            eq("test-audience"),
            eq("a b"),
            eq(30),
            eq(mapOf("p" to "1")),
            eq(mapOf("h" to "2")),
            any()
        )
    }

    @Test
    fun `should use defaults when optional arguments are omitted`() {
        val handler = GetApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>("audience" to "test-audience")
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockCredentialsManager).getApiCredentials(
            eq("test-audience"),
            isNull(),
            eq(0),
            eq(mapOf()),
            eq(mapOf()),
            any()
        )
    }

    @Test
    fun `should error when audience is missing`() {
        val handler = GetApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).error(eq("UNKNOWN ERROR"), any(), anyOrNull())
        verify(mockCredentialsManager, never()).getApiCredentials(
            anyString(), anyOrNull(), anyInt(), anyMap(), anyMap(), any()
        )
    }

    @Test
    fun `should call result error on failure`() {
        val handler = GetApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>("audience" to "test-audience")
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()
        `when`(exception.message).thenReturn("test-message")

        doAnswer {
            val cb = it.getArgument<Callback<APICredentials, CredentialsManagerException>>(5)
            cb.onFailure(exception)
        }.`when`(mockCredentialsManager).getApiCredentials(
            anyString(), anyOrNull(), anyInt(), anyMap(), anyMap(), any()
        )

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).error(eq("test-message"), eq("test-message"), any())
    }

    @Test
    fun `should call result success on success`() {
        val handler = GetApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>("audience" to "test-audience")
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val apiCredentials = APICredentials(
            accessToken = "api-access-token",
            type = "Bearer",
            expiresAt = Date(0),
            scope = "a b"
        )

        whenever(
            mockCredentialsManager.getApiCredentials(
                anyString(), anyOrNull(), anyInt(), anyMap(), anyMap(), any()
            )
        ).thenAnswer {
            val callback =
                it.getArgument<Callback<APICredentials, CredentialsManagerException>>(5)
            callback.onSuccess(apiCredentials)
        }

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val resultMap = captor.firstValue
        MatcherAssert.assertThat(
            resultMap["accessToken"],
            CoreMatchers.equalTo("api-access-token")
        )
        MatcherAssert.assertThat(
            resultMap["tokenType"],
            CoreMatchers.equalTo("Bearer")
        )
        MatcherAssert.assertThat(
            resultMap["scopes"],
            CoreMatchers.equalTo(listOf("a", "b"))
        )
        MatcherAssert.assertThat(
            resultMap["expiresAt"],
            CoreMatchers.equalTo(Date(0).toInstant().toString())
        )
    }
}
