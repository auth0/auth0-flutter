package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.PhoneAuthenticationMethodType
import com.auth0.android.request.Request
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class EnrollPhoneRequestHandlerTest {

    @Test
    fun `should call enrollPhone with sms type`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "phoneNumber" to "+1234567890",
            "type" to "sms"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.enrollPhone(any(), any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enrollPhone(eq("+1234567890"), eq(PhoneAuthenticationMethodType.SMS))
    }

    @Test
    fun `should call enrollPhone with voice type`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "phoneNumber" to "+1234567890",
            "type" to "voice"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.enrollPhone(any(), any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enrollPhone(eq("+1234567890"), eq(PhoneAuthenticationMethodType.VOICE))
    }

    @Test
    fun `should call result success with challenge map on success`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "phoneNumber" to "+1234567890",
            "type" to "sms"
        )
        val request = MethodCallRequest(account = mockAccount, options)

        val mockChallenge = mock<EnrollmentChallenge>()
        whenever(mockChallenge.id).thenReturn("phone|test123")
        whenever(mockChallenge.authSession).thenReturn("session123")

        whenever(mockClient.enrollPhone(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<EnrollmentChallenge, MyAccountException>>(0)
            callback.onSuccess(mockChallenge)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MyAccountException>>()
        val options = hashMapOf<String, Any>(
            "phoneNumber" to "+1234567890",
            "type" to "sms"
        )
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("invalid_phone")
        whenever(exception.getDescription()).thenReturn("Invalid phone number")
        whenever(exception.statusCode).thenReturn(400)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.enrollPhone(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<EnrollmentChallenge, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("invalid_phone"), eq("Invalid phone number"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when phoneNumber is missing`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>("type" to "sms")
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when type is missing`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val options = hashMapOf<String, Any>("phoneNumber" to "+1234567890")
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockClient, request, mockResult)
    }
}
