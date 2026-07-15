package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.request.ActorToken
import com.auth0.android.callback.Callback
import com.auth0.android.request.AuthenticationRequest
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.JwtTestUtils
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*

@RunWith(RobolectricTestRunner::class)
class CustomTokenExchangeApiRequestHandlerTest {
    @Test
    fun `should send error when missing subjectToken`() {
        val options = hashMapOf("subjectTokenType" to "urn:acme:legacy-token")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("INVALID_ARGUMENT"), any(), anyOrNull())
    }

    @Test
    fun `should send error when missing subjectTokenType`() {
        val options = hashMapOf("subjectToken" to "external-token-123")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("INVALID_ARGUMENT"), any(), anyOrNull())
    }

    @Test
    fun `should send error when subjectToken is not a String`() {
        val options = hashMapOf<String, Any>(
            "subjectToken" to 123,
            "subjectTokenType" to "urn:acme:legacy-token"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("INVALID_ARGUMENT"), any(), anyOrNull())
    }

    @Test
    fun `should call success with required parameters only`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-123",
            "subjectTokenType" to "urn:acme:legacy-token"
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            "urn:acme:legacy-token",
            "external-token-123",
            null,
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
            "subjectTokenType" to "urn:acme:legacy-token"
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
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
            "subjectTokenType" to "urn:acme:legacy-token",
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
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
            "subjectTokenType" to "urn:acme:legacy-token",
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

        whenever(mockApi.customTokenExchange(any(), any(), eq("org_abc123"), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            "urn:acme:legacy-token",
            "external-token-org",
            "org_abc123",
            null
        )
        verify(mockResult).success(any())
    }

    @Test
    fun `should pass actor token when actorToken and actorTokenType provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-actor",
            "subjectTokenType" to "urn:acme:legacy-token",
            "actorToken" to "actor-token-value",
            "actorTokenType" to "urn:ietf:params:oauth:token-type:id_token"
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
            null,
            Date(),
            "openid"
        )

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), any())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            eq("urn:acme:legacy-token"),
            eq("external-token-actor"),
            isNull(),
            eq(ActorToken("actor-token-value", "urn:ietf:params:oauth:token-type:id_token"))
        )
        verify(mockResult).success(any())
    }

    @Test
    fun `should not pass actor token when only actorToken provided`() {
        val options = hashMapOf(
            "subjectToken" to "external-token-actor",
            "subjectTokenType" to "urn:acme:legacy-token",
            "actorToken" to "actor-token-value"
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

        whenever(mockApi.customTokenExchange(any(), any(), isNull(), isNull())).thenReturn(mockRequest)
        whenever(mockRequest.validateClaims()).thenReturn(mockRequest)

        doAnswer {
            val callback = it.arguments[0] as Callback<Credentials, AuthenticationException>
            callback.onSuccess(credentials)
            null
        }.whenever(mockRequest).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).customTokenExchange(
            eq("urn:acme:legacy-token"),
            eq("external-token-actor"),
            isNull(),
            isNull()
        )
        verify(mockResult).success(any())
    }

    @Test
    fun `should return correct method name`() {
        val handler = CustomTokenExchangeApiRequestHandler()
        assertThat(handler.method, equalTo("auth#customTokenExchange"))
    }
}
