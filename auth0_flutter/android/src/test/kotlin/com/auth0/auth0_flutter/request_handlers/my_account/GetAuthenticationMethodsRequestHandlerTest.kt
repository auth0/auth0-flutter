package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.AuthenticationMethodType
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
class GetAuthenticationMethodsRequestHandlerTest {

    @Test
    fun `should call getAuthenticationMethods with null type when not provided`() {
        val handler = GetAuthenticationMethodsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<AuthenticationMethod>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        whenever(mockClient.getAuthenticationMethods(anyOrNull())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).getAuthenticationMethods(null)
    }

    @Test
    fun `should map the type filter and pass it to the client`() {
        val handler = GetAuthenticationMethodsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<AuthenticationMethod>, MyAccountException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("type" to "push-notification")
        )

        whenever(mockClient.getAuthenticationMethods(anyOrNull())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).getAuthenticationMethods(AuthenticationMethodType.PUSH)
    }

    @Test
    fun `should call result success with mapped methods on success`() {
        val handler = GetAuthenticationMethodsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<AuthenticationMethod>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        val mockMethod = mock<AuthenticationMethod>()
        whenever(mockMethod.id).thenReturn("test-id")
        whenever(mockMethod.type).thenReturn("phone")
        whenever(mockMethod.createdAt).thenReturn("2026-01-01T00:00:00.000Z")

        whenever(mockClient.getAuthenticationMethods(anyOrNull())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<List<AuthenticationMethod>, MyAccountException>>(0)
            callback.onSuccess(listOf(mockMethod))
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = GetAuthenticationMethodsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<AuthenticationMethod>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("insufficient_scope")
        whenever(exception.getDescription()).thenReturn("Insufficient scope")
        whenever(exception.statusCode).thenReturn(403)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.getAuthenticationMethods(anyOrNull())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<List<AuthenticationMethod>, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("insufficient_scope"), eq("Insufficient scope"), any())
    }
}
