package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class DeleteAuthenticationMethodRequestHandlerTest {

    @Test
    fun `should call deleteAuthenticationMethod with the correct id`() {
        val handler = DeleteAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<Void?, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.deleteAuthenticationMethod(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).deleteAuthenticationMethod(eq("phone|test123"))
    }

    @Test
    fun `should call result success with null on success`() {
        val handler = DeleteAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<Void?, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.deleteAuthenticationMethod(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<Void?, MyAccountException>>(0)
            callback.onSuccess(null)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(isNull())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = DeleteAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<Void?, MyAccountException>>()
        val options = hashMapOf<String, Any>("id" to "phone|test123")
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("not_found")
        whenever(exception.getDescription()).thenReturn("Method not found")
        whenever(exception.statusCode).thenReturn(404)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.deleteAuthenticationMethod(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<Void?, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("not_found"), eq("Method not found"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when id is missing`() {
        val handler = DeleteAuthenticationMethodRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }
}
