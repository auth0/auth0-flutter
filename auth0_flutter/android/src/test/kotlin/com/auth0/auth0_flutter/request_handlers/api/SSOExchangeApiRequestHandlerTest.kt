package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.SSOCredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SSOExchangeApiRequestHandlerTest {
    @Test
    fun `should throw when missing refreshToken`() {
        val options = hashMapOf<String, Any>()
        val handler = SSOExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockApi, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'refreshToken' is not provided.")
        )
    }

    @Test
    fun `should call ssoExchange with the correct refreshToken`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).ssoExchange("test-refresh-token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token",
            "parameters" to mapOf("key1" to "value1", "key2" to "value2")
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addParameters(any())).thenReturn(mockBuilder)

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder).addParameters(mapOf("key1" to "value1", "key2" to "value2"))
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should not configure the parameters when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder, times(0)).addParameters(any())
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the headers when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token",
            "headers" to mapOf("X-Custom" to "custom-value", "Authorization" to "Bearer token")
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addHeader(any(), any())).thenReturn(mockBuilder)

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder).addHeader("X-Custom", "custom-value")
        verify(mockBuilder).addHeader("Authorization", "Bearer token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should not configure the headers when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder, times(0)).addHeader(any(), any())
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = AuthenticationException(code = "test-code", description = "test-description")

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<SSOCredentials, AuthenticationException>>(0)
            callback.onFailure(exception)
        }

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val mockSSOCredentials = mock<SSOCredentials>()
        whenever(mockSSOCredentials.sessionTransferToken).thenReturn("sso-token")
        whenever(mockSSOCredentials.issuedTokenType).thenReturn("session_transfer")
        whenever(mockSSOCredentials.expiresIn).thenReturn(60)
        whenever(mockSSOCredentials.idToken).thenReturn("id-token")
        whenever(mockSSOCredentials.refreshToken).thenReturn("new-refresh-token")

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<SSOCredentials, AuthenticationException>>(0)
            callback.onSuccess(mockSSOCredentials)
        }

        handler.handle(mockApi, request, mockResult)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val resultMap = captor.firstValue
        assertThat(resultMap["sessionTransferToken"], equalTo("sso-token"))
        assertThat(resultMap["tokenType"], equalTo("session_transfer"))
        assertThat(resultMap["expiresIn"], equalTo(60))
        assertThat(resultMap["idToken"], equalTo("id-token"))
        assertThat(resultMap["refreshToken"], equalTo("new-refresh-token"))
    }

    @Test
    fun `should not include refreshToken in result when absent`() {
        val options = hashMapOf(
            "refreshToken" to "test-refresh-token"
        )
        val handler = SSOExchangeApiRequestHandler()
        val mockBuilder = mock<Request<SSOCredentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val mockSSOCredentials = mock<SSOCredentials>()
        whenever(mockSSOCredentials.sessionTransferToken).thenReturn("sso-token")
        whenever(mockSSOCredentials.issuedTokenType).thenReturn("session_transfer")
        whenever(mockSSOCredentials.expiresIn).thenReturn(60)
        whenever(mockSSOCredentials.idToken).thenReturn("id-token")
        whenever(mockSSOCredentials.refreshToken).thenReturn(null)

        whenever(mockApi.ssoExchange("test-refresh-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<SSOCredentials, AuthenticationException>>(0)
            callback.onSuccess(mockSSOCredentials)
        }

        handler.handle(mockApi, request, mockResult)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())

        assertThat(captor.firstValue.containsKey("refreshToken"), equalTo(false))
    }
}
