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
class EnrollPhoneRequestHandlerTest {

    @Test
    fun `should call enroll with Phone type`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "mfaToken" to "mfa-token",
                "phoneNumber" to "+1234567890"
            )
        )

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enroll(eq(MfaEnrollmentType.Phone("+1234567890")))
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "mfaToken" to "mfa-token",
                "phoneNumber" to "+1234567890"
            )
        )
        val exception = mock<MfaEnrollmentException>()
        whenever(exception.getCode()).thenReturn("invalid_phone")
        whenever(exception.getDescription()).thenReturn("Invalid phone")
        whenever(exception.statusCode).thenReturn(400)

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<EnrollmentChallenge, MfaEnrollmentException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("invalid_phone"), eq("Invalid phone"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when phoneNumber is missing`() {
        val handler = EnrollPhoneRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("mfaToken" to "mfa-token")
        )

        handler.handle(mockClient, request, mockResult)
    }
}
