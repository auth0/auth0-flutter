package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.android.result.AuthenticationMethod
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GetAuthenticationMethodRequestHandlerTest {

    @Test
    fun `should call getAuthenticationMethodById with the correct id`() {
        val handler = GetAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.getAuthenticationMethodById(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).getAuthenticationMethodById(eq("phone|test123"))
    }

    @Test
    fun `should call result success with mapped method on success`() {
        val handler = GetAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)

        val mockMethod = mock<AuthenticationMethod>()
        whenever(mockMethod.id).thenReturn("phone|test123")
        whenever(mockMethod.type).thenReturn("phone")
        whenever(mockMethod.createdAt).thenReturn("2026-01-01T00:00:00.000Z")

        whenever(mockClient.getAuthenticationMethodById(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<AuthenticationMethod, MyAccountException>>(0)
            callback.onSuccess(mockMethod)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = GetAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<AuthenticationMethod, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("not_found")
        whenever(exception.getDescription()).thenReturn("Not found")
        whenever(exception.statusCode).thenReturn(404)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.getAuthenticationMethodById(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<AuthenticationMethod, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("not_found"), eq("Not found"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when id is missing`() {
        val handler = GetAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }
}
