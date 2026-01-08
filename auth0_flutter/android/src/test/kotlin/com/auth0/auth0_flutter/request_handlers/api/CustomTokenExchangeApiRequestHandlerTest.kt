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
        val options = hashMapOf("subjectTokenType" to "http://acme.com/legacy-token")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockApi,
                request,
                mockResult
            )
        }
    }

    @Test
    fun `should throw when missing subjectTokenType`() {
        val options = hashMapOf("subjectToken" to "existing-token")
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockApi,
                request,
                mockResult
            )
        }
    }

    @Test
    fun `should call customTokenExchange with correct parameters`() {
        val options = hashMapOf(
            "subjectToken" to "existing-token",
            "subjectTokenType" to "http://acme.com/legacy-token",
            "scopes" to arrayListOf("openid", "profile", "email"),
            "audience" to "https://example.com/api",
            "parameters" to hashMapOf("test" to "test-123")
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.customTokenExchange("http://acme.com/legacy-token", "existing-token"))
            .thenReturn(mockBuilder)
        whenever(mockBuilder.setScope(any())).thenReturn(mockBuilder)
        whenever(mockBuilder.setAudience(any())).thenReturn(mockBuilder)
        whenever(mockBuilder.addParameters(any())).thenReturn(mockBuilder)
        whenever(mockBuilder.validateClaims()).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).customTokenExchange("http://acme.com/legacy-token", "existing-token")
        verify(mockBuilder).setScope("openid profile email")
        verify(mockBuilder).setAudience("https://example.com/api")
        verify(mockBuilder).addParameters(any())
        verify(mockBuilder).validateClaims()
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should handle success callback`() {
        val options = hashMapOf(
            "subjectToken" to "existing-token",
            "subjectTokenType" to "http://acme.com/legacy-token"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        val expiresAt = Date(dateFormat.parse("2023-12-23T12:34:56.789Z").time)
        val idToken = JwtTestUtils.createJwt()

        val credentials = Credentials(
            "id-token-value",
            "access-token-value",
            "bearer",
            "refresh-token-value",
            expiresAt,
            "openid profile email"
        )

        whenever(mockApi.customTokenExchange("http://acme.com/legacy-token", "existing-token"))
            .thenReturn(mockBuilder)
        whenever(mockBuilder.validateClaims()).thenReturn(mockBuilder)

        doAnswer { invocation ->
            val callback = invocation.getArgument<Callback<Credentials, AuthenticationException>>(0)
            callback.onSuccess(credentials)
            null
        }.whenever(mockBuilder).start(any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockResult).success(argThat { result ->
            result is Map<*, *> &&
                    result["accessToken"] == "access-token-value" &&
                    result["idToken"] == "id-token-value"
        })
    }

    @Test
    fun `should handle error callback`() {
        val options = hashMapOf(
            "subjectToken" to "existing-token",
            "subjectTokenType" to "http://acme.com/legacy-token"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<AuthenticationException>()
        whenever(exception.getCode()).thenReturn("invalid_grant")
        whenever(exception.getDescription()).thenReturn("Invalid token")

        whenever(mockApi.customTokenExchange("http://acme.com/legacy-token", "existing-token"))
            .thenReturn(mockBuilder)
        whenever(mockBuilder.validateClaims()).thenReturn(mockBuilder)

        doAnswer { invocation ->
            val callback = invocation.getArgument<Callback<Credentials, AuthenticationException>>(0)
            callback.onFailure(exception)
            null
        }.whenever(mockBuilder).start(any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockResult).error("invalid_grant", "Invalid token", any())
    }

    @Test
    fun `should work without optional parameters`() {
        val options = hashMapOf(
            "subjectToken" to "existing-token",
            "subjectTokenType" to "http://acme.com/legacy-token"
        )
        val handler = CustomTokenExchangeApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.customTokenExchange("http://acme.com/legacy-token", "existing-token"))
            .thenReturn(mockBuilder)
        whenever(mockBuilder.validateClaims()).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).customTokenExchange("http://acme.com/legacy-token", "existing-token")
        verify(mockBuilder).validateClaims()
        verify(mockBuilder, never()).setScope(any())
        verify(mockBuilder, never()).setAudience(any())
        verify(mockBuilder).start(any())
    }
}
