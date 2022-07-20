package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.DatabaseUser

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
class SignupApiRequestHandlerTest {
    @Test
    fun `should throw when missing email`() {
        val options = hashMapOf<String, Any>(
            "password" to "test-pass",
            "connection" to "test-connection"
        )
        val handler = SignupApiRequestHandler()
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
            equalTo("Required property 'email' is not provided.")
        )
    }

    @Test
    fun `should throw when missing password`() {
        val options = hashMapOf<String, Any>(
            "email" to "test-email",
            "connection" to "test-connection"
        )
        val handler = SignupApiRequestHandler()
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
            equalTo("Required property 'password' is not provided.")
        )
    }

    @Test
    fun `should throw when missing connection`() {
        val options = hashMapOf<String, Any>(
            "email" to "test-email",
            "password" to "test-pass"
        )
        val handler = SignupApiRequestHandler()
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
            equalTo("Required property 'connection' is not provided.")
        )
    }

    @Test
    fun `should call createUser with the correct parameters`() {
        val options = hashMapOf(
            "email" to "test-email",
            "password" to "test-pass",
            "connection" to "test-connection"
        )
        val handler = SignupApiRequestHandler()
        val mockBuilder = mock<Request<DatabaseUser, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi)
            .createUser(any(), any(), anyOrNull(), any(), anyOrNull())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).createUser("test-email", "test-pass", null, "test-connection", null)
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
            "email" to "test-email",
            "password" to "test-pass",
            "connection" to "test-connection",
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val handler = SignupApiRequestHandler()
        val mockBuilder = mock<Request<DatabaseUser, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).createUser(any(), any(), anyOrNull(), any(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any())

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
    }

    @Test
    fun `should not configure the parameters when not provided`() {
        val options = hashMapOf(

            "email" to "test-email",
            "password" to "test-pass",
            "connection" to "test-connection",
        )
        val handler = SignupApiRequestHandler()
        val mockBuilder = mock<Request<DatabaseUser, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).createUser(any(), any(), anyOrNull(), any(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockBuilder, times(0)).addParameters(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "email" to "test-email",
            "password" to "test-pass",
            "connection" to "test-connection",
        )
        val handler = SignupApiRequestHandler()
        val mockBuilder = mock<Request<DatabaseUser, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockBuilder).`when`(mockApi)
            .createUser(any(), any(), anyOrNull(), any(), anyOrNull())
        doAnswer {
            val ob = it.getArgument<Callback<DatabaseUser, AuthenticationException>>(0)
            ob.onFailure(exception)
        }.`when`(mockBuilder).start(any())

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
            "email" to "test-email",
            "password" to "test-pass",
            "connection" to "test-connection",
        )
        val handler = SignupApiRequestHandler()
        val mockBuilder = mock<Request<DatabaseUser, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val user = DatabaseUser(options["email"] as String, null, false)

        doReturn(mockBuilder).`when`(mockApi)
            .createUser(any(), any(), anyOrNull(), any(), anyOrNull())
        doAnswer {
            val ob = it.getArgument<Callback<DatabaseUser, AuthenticationException>>(0)
            ob.onSuccess(user)
        }.`when`(mockBuilder).start(any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        assertThat((captor.firstValue as Map<*, *>)["email"], equalTo(user.email))
        assertThat(
            (captor.firstValue as Map<*, *>)["emailVerified"],
            equalTo(user.isEmailVerified)
        )
        assertThat((captor.firstValue as Map<*, *>)["username"], equalTo(user.username))

    }
}
