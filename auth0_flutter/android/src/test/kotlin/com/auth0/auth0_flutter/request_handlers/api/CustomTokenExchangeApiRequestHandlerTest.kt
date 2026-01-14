package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.AuthenticationRequest
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.JwtTestUtils
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*

@RunWith(RobolectricTestRunner::class)
class CustomTokenExchangeApiRequestHandlerTest {
    @Test
    fun `should throw when missing subjectToken`() {
        val options = hashMapOf("subjectTokenType" to "urn:ietf:params:oauth:token-type:jwt")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockApi, request, mockResult)
        }
    }

    @Test
    fun `should throw when missing subjectTokenType`() {
        val options = hashMapOf("subjectToken" to "external-token-123")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockApi, request, mockResult)
        }
    }

    @Test
    fun `should call success with required parameters only`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-123",
            "subjectTokenType" to "urn:ietf:params:oauth:token-type:jwt"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val accessToken = JwtTestUtils.createJwt("openid")
        val idToken = JwtTestUtils.createJwt("openid")
        val refreshToken = "refresh-token"
        val expiresAt = Date()

        val credentials = Credentials(
            idToken,
            accessToken,
            "Bearer",
            refreshToken,
            expiresAt,
            "openid profile email"
        )

        whenever(mockApi.customTokenExchange(any(), any(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            "urn:ietf:params:oauth:token-type:jwt",
            "external-token-123",
            null
        )
        verify(mockRequest).validateClaims()
        verify(mockRequest).start(any())
        verify(mockResult).success(any())
    }

    @Test
    fun `should handle error callback`() {
        val options = hashMapOf(
            "subjectToken" to "invalid-token",
            "subjectTokenType" to "urn:ietf:params:oauth:token-type:jwt"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<AuthenticationException> {
            on { getCode() } doReturn "invalid_token"
            on { getDescription() } doReturn "Token validation failed"
        }

        whenever(mockApi.customTokenExchange(any(), any(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onFailure(exception)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("invalid_token"), eq("Token validation failed"), any())
    }

    @Test
    fun `should include audience when provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-456",
            "subjectTokenType" to "urn:example:custom-token",
            "audience" to "https://myapi.example.com"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val credentials = Credentials(
            JwtTestUtils.createJwt("openid"),
            JwtTestUtils.createJwt("openid"),
            "Bearer",
            "refresh-token",
            Date(),
            "openid"
        )

        whenever(mockApi.customTokenExchange(any(), any(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.setAudience(any())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockRequest).setAudience("https://myapi.example.com")
        verify(mockResult).success(any())
    }

    @Test
    fun `should include scopes when provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-789",
            "subjectTokenType" to "urn:ietf:params:oauth:token-type:jwt",
            "scopes" to arrayListOf("openid", "profile", "email", "read:data")
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val credentials = Credentials(
            JwtTestUtils.createJwt("openid"),
            JwtTestUtils.createJwt("openid"),
            "Bearer",
            "refresh-token",
            Date(),
            "openid profile email read:data"
        )

        whenever(mockApi.customTokenExchange(any(), any(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.setScope(any())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockRequest).setScope("openid profile email read:data")
        verify(mockResult).success(any())
    }

    @Test
    fun `should include all optional parameters when provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-full",
            "subjectTokenType" to "urn:example:full-token",
            "audience" to "https://api.example.com",
            "scopes" to arrayListOf("openid", "profile", "email")
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val credentials = Credentials(
            JwtTestUtils.createJwt("openid"),
            JwtTestUtils.createJwt("openid"),
            "Bearer",
            "refresh-token",
            Date(),
            "openid profile email"
        )

        whenever(mockApi.customTokenExchange(any(), any(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.setAudience(any())).thenReturn(mockRequest)
        whenever(mockRequest.setScope(any())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockRequest).setAudience("https://api.example.com")
        verify(mockRequest).setScope("openid profile email")
        verify(mockRequest).validateClaims()
        verify(mockResult).success(any())
    }

    @Test
    fun `should include organization when provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-org",
            "subjectTokenType" to "urn:ietf:params:oauth:token-type:jwt",
            "organization" to "org_abc123"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockRequest = mock<AuthenticationRequest>()
        val request = MethodCallRequest(account = mockAccount, options)

        val credentials = Credentials(
            JwtTestUtils.createJwt("openid"),
            JwtTestUtils.createJwt("openid"),
            "Bearer",
            "refresh-token",
            Date(),
            "openid"
        )

        whenever(mockApi.customTokenExchange(any(), any(), eq("org_abc123"))).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            "urn:ietf:params:oauth:token-type:jwt",
            "external-token-org",
            "org_abc123"
        )
        verify(mockResult).success(any())
    }

    @Test
    fun `should return correct method name`() {
        val handler = CustomTokenExchangeApiRequestHandler()
        assertThat(handler.method, equalTo("auth#customTokenExchange"))
    }
}
