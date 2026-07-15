package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.Auth0
import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaEnrollmentType
import com.auth0.android.authentication.mfa.MfaException.MfaEnrollmentException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class EnrollTotpRequestHandlerTest {

    @Test
    fun `should call enroll with Otp type`() {
        val handler = EnrollTotpRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("mfaToken" to "mfa-token")
        )

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enroll(eq(MfaEnrollmentType.Otp))
    }

    @Test
    fun `should call result success with challenge on success`() {
        val handler = EnrollTotpRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("mfaToken" to "mfa-token")
        )

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<EnrollmentChallenge, MfaEnrollmentException>>(0)
            callback.onSuccess(mock<EnrollmentChallenge>())
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollTotpRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("mfaToken" to "mfa-token")
        )
        val exception = mock<MfaEnrollmentException>()
        whenever(exception.getCode()).thenReturn("invalid_request")
        whenever(exception.getDescription()).thenReturn("Invalid request")
        whenever(exception.statusCode).thenReturn(400)

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<EnrollmentChallenge, MfaEnrollmentException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("invalid_request"), eq("Invalid request"), any())
    }
}
