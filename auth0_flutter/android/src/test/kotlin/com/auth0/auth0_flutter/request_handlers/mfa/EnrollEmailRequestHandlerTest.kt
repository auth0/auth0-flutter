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
class EnrollEmailRequestHandlerTest {

    @Test
    fun `should call enroll with Email type`() {
        val handler = EnrollEmailRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<EnrollmentChallenge, MfaEnrollmentException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "mfaToken" to "mfa-token",
                "email" to "user@example.com"
            )
        )

        whenever(mockClient.enroll(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enroll(eq(MfaEnrollmentType.Email("user@example.com")))
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when email is missing`() {
        val handler = EnrollEmailRequestHandler()
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
