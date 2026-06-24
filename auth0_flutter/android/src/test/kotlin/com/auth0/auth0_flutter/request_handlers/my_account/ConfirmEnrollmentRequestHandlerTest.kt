package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.android.result.AuthenticationMethod
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ConfirmEnrollmentRequestHandlerTest {

    @Test
    fun `should call verify with correct parameters`() {
        val handler = ConfirmEnrollmentRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "id" to "push|test123",
            "authSession" to "session456"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.verify(any(), any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).verify(eq("push|test123"), eq("session456"))
    }

    @Test
    fun `should call result success with mapped method on success`() {
        val handler = ConfirmEnrollmentRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "id" to "push|test123",
            "authSession" to "session456"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        val mockMethod = mock<AuthenticationMethod>()
        whenever(mockMethod.id).thenReturn("push|test123")
        whenever(mockMethod.type).thenReturn("push")
        whenever(mockMethod.createdAt).thenReturn("2026-01-01")

        whenever(mockClient.verify(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<AuthenticationMethod, MyAccountException>>(0)
            callback.onSuccess(mockMethod)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        val captor = argumentCaptor<Map<String, Any?>>()
        verify(mockResult).success(captor.capture())

        val result = captor.firstValue
        assertThat(result["id"], equalTo("push|test123"))
        assertThat(result["type"], equalTo("push"))
    }

    @Test
    fun `should call result error on failure`() {
        val handler = ConfirmEnrollmentRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "id" to "push|test123",
            "authSession" to "session456"
        )
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("invalid_session")
        whenever(exception.getDescription()).thenReturn("Invalid session")
        whenever(exception.statusCode).thenReturn(403)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.verify(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<AuthenticationMethod, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("invalid_session"), eq("Invalid session"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when id is missing`() {
        val handler = ConfirmEnrollmentRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>(
            "authSession" to "session456"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when authSession is missing`() {
        val handler = ConfirmEnrollmentRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>(
            "id" to "push|test123"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }
}
