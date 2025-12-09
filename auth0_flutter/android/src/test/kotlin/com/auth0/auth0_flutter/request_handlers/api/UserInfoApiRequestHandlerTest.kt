package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.UserProfile

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.sub
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class UserInfoApiRequestHandlerTest {
    @Test
    fun `should throw when missing accessToken`() {
        val options = hashMapOf<String, Any>()
        val handler = UserInfoApiRequestHandler()
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
            equalTo("Required property 'accessToken' is not provided.")
        )
    }

    @Test
    fun `should call userInfo with the correct parameters`() {
        val options = hashMapOf(
            "accessToken" to "test-token",
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).userInfo("test-token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
            "accessToken" to "test-token",
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)
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
            "accessToken" to "test-token",
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder, times(0)).addParameters(any())
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should default tokenType to Bearer when not provided`() {
        val options = hashMapOf(
            "accessToken" to "test-token",
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addHeader(any(), any())).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder).addHeader("Authorization", "Bearer test-token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should use custom tokenType when provided`() {
        val options = hashMapOf(
            "accessToken" to "test-token",
            "tokenType" to "DPoP"
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.addHeader(any(), any())).thenReturn(mockBuilder)

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder).addHeader("Authorization", "DPoP test-token")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "accessToken" to "test-token",
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<UserProfile, AuthenticationException>>(0)
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
            "accessToken" to "test-token",
        )
        val handler = UserInfoApiRequestHandler()
        val mockBuilder = mock<Request<UserProfile, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val user = UserProfile(
            "",
            "John Doe",
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            mapOf("sub" to "test-sub"),
            null,
            null,
            null
        )

        whenever(mockApi.userInfo("test-token")).thenReturn(mockBuilder)
        whenever(mockBuilder.start(any())).thenAnswer {
            val callback = it.getArgument<Callback<UserProfile, AuthenticationException>>(0)
            callback.onSuccess(user)
        }

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())
        
        val resultMap = captor.firstValue

        assertThat(resultMap["sub"], equalTo(user.sub))
        assertThat(resultMap["name"], equalTo(user.name))

    }
}
