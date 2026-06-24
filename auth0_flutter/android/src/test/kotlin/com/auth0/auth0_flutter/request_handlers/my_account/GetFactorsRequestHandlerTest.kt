package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.android.result.Factor
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GetFactorsRequestHandlerTest {

    @Test
    fun `should call getFactors on the client`() {
        val handler = GetFactorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<Factor>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        whenever(mockClient.getFactors()).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).getFactors()
    }

    @Test
    fun `should call result success with mapped factors on success`() {
        val handler = GetFactorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<Factor>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        val mockFactor = mock<Factor>()
        whenever(mockFactor.type).thenReturn("sms")
        whenever(mockFactor.usage).thenReturn(listOf("secondary"))

        whenever(mockClient.getFactors()).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<List<Factor>, MyAccountException>>(0)
            callback.onSuccess(listOf(mockFactor))
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        val captor = argumentCaptor<List<Map<String, Any?>>>()
        verify(mockResult).success(captor.capture())

        val result = captor.firstValue
        assertThat(result.size, equalTo(1))
        assertThat(result[0]["type"], equalTo("sms"))
        assertThat(result[0]["usage"], equalTo(listOf("secondary")))
    }

    @Test
    fun `should call result error on failure`() {
        val handler = GetFactorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<List<Factor>, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("access_denied")
        whenever(exception.getDescription()).thenReturn("Access denied")
        whenever(exception.statusCode).thenReturn(403)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.getFactors()).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<List<Factor>, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("access_denied"), eq("Access denied"), any())
    }
}
