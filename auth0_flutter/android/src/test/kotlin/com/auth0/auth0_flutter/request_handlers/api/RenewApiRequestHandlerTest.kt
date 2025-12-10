package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
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
class RenewApiRequestHandlerTest {
    @Test
    fun `should throw when missing refreshToken`() {
        val options = hashMapOf<String, Any>()
        val handler = RenewApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockApi,
                request,
                mockResult
            )
        }

        assertThat(
            exception.message,
            equalTo("Required property 'refreshToken' is not provided.")
        )
    }

    @Test
    fun `should call renewAuth with the correct parameters`() {
        val options = hashMapOf(
            "refreshToken" to "test-token"
        )
        val handler = RenewApiRequestHandler()
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).renewAuth("test-token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the scopes when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
            "scopes" to arrayListOf("scope1", "scope2")
        )
        val handler = RenewApiRequestHandler()
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockApi = mock<AuthenticationAPIClient>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addParameter("scope", "scope1 scope2")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder).addParameter("scope", "scope1 scope2")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should not configure the scopes when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        )
        val handler = RenewApiRequestHandler()
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockApi = mock<AuthenticationAPIClient>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder, times(0)).addParameter(any(), any())
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val handler = RenewApiRequestHandler()
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockApi = mock<AuthenticationAPIClient>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addParameters(any())).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder).addParameters(
            mapOf(
                "test" to "test-value",
                "test2" to "test-value"
            )
        )
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should not configure the parameters when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        )
        val handler = RenewApiRequestHandler()
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockApi = mock<AuthenticationAPIClient>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder, times(0)).addParameters(any())
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        )
        val handler = RenewApiRequestHandler()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            callback.onFailure(exception)
        }

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        )
        val handler = RenewApiRequestHandler()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "test", "", null, Date(), "scope1 scope2")

        val mockBuilder = mock<Request<Credentials, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()

        whenever(mockApi.renewAuth("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            callback.onSuccess(credentials)
        }

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val formattedDate = credentials.expiresAt.toInstant().toString()
        
        val resultMap = captor.firstValue

        assertThat(
            resultMap["accessToken"],
            equalTo(credentials.accessToken)
        )
        assertThat(resultMap["idToken"], equalTo(credentials.idToken))
        assertThat(
            resultMap["refreshToken"],
            equalTo(credentials.refreshToken)
        )
        assertThat(
            resultMap["expiresAt"] as String,
            equalTo(formattedDate)
        )
        assertThat(
            resultMap["scopes"],
            equalTo(listOf("scope1", "scope2"))
        )
        assertThat(
            (resultMap["userProfile"] as Map<*, *>)["name"],
            equalTo("John Doe")
        )
    }
}
