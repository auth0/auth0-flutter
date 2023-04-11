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
class LoginWithOtpApiRequestHandlerTest {
    @Test
    fun `should throw when missing otp`() {
        val options = hashMapOf("mfaToken" to "test-mfaToken")
        val handler = LoginWithOtpApiRequestHandler()
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
            equalTo("Required property 'otp' is not provided.")
        )
    }

    @Test
    fun `should throw when missing mfaToken`() {
        val options = hashMapOf("otp" to "test-otp")
        val handler = LoginWithOtpApiRequestHandler()
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
            equalTo("Required property 'mfaToken' is not provided.")
        )
    }

    @Test
    fun `should call loginWithOTp with the correct parameters`() {
        val options = hashMapOf(
            "otp" to "test-otp",
            "mfaToken" to "test-mfaToken"
        )
        val handler = LoginWithOtpApiRequestHandler()
        val mockLoginBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockLoginBuilder).`when`(mockApi).loginWithOTP(any(), any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        verify(mockApi).loginWithOTP("test-mfaToken", "test-otp")
        verify(mockLoginBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "otp" to "test-otp",
            "mfaToken" to "test-mfaToken"
        )
        val handler = LoginWithOtpApiRequestHandler()
        val mockLoginBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockLoginBuilder).`when`(mockApi).loginWithOTP(any(), any())
        doAnswer {
            val ob = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            ob.onFailure(exception)
        }.`when`(mockLoginBuilder).start(any())

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
            "otp" to "test-otp",
            "mfaToken" to "test-mfaToken"
        )
        val handler = LoginWithOtpApiRequestHandler()
        val mockLoginBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "test", "", null, Date(), "scope1 scope2")

        doReturn(mockLoginBuilder).`when`(mockApi).loginWithOTP(any(), any())
        doAnswer {
            val ob = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            ob.onSuccess(credentials)
        }.`when`(mockLoginBuilder).start(any())

        handler.handle(
            mockApi,
            request,
            mockResult
        )

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val sdf =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US)

        val formattedDate = sdf.format(credentials.expiresAt)

        assertThat((captor.firstValue as Map<*, *>)["accessToken"], equalTo(credentials.accessToken))
        assertThat((captor.firstValue as Map<*, *>)["idToken"], equalTo(credentials.idToken))
        assertThat((captor.firstValue as Map<*, *>)["refreshToken"], equalTo(credentials.refreshToken))
        assertThat((captor.firstValue as Map<*, *>)["expiresAt"] as String, equalTo(formattedDate))
        assertThat((captor.firstValue as Map<*, *>)["scopes"], equalTo(listOf("scope1", "scope2")))
        assertThat(((captor.firstValue as Map<*, *>)["userProfile"] as Map<*, *>)["name"], equalTo("John Doe"))
    }
}
