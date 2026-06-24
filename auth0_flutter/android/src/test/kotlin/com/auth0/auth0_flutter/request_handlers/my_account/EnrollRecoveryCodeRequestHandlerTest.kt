package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.android.result.RecoveryCodeEnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class EnrollRecoveryCodeRequestHandlerTest {

    @Test
    fun `should call enrollRecoveryCode on the client`() {
        val handler = EnrollRecoveryCodeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<RecoveryCodeEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        whenever(mockClient.enrollRecoveryCode()).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enrollRecoveryCode()
    }

    @Test
    fun `should call result success with challenge map on success`() {
        val handler = EnrollRecoveryCodeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<RecoveryCodeEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        val mockChallenge = mock<RecoveryCodeEnrollmentChallenge>()
        whenever(mockChallenge.id).thenReturn("recovery-code|test123")
        whenever(mockChallenge.authSession).thenReturn("session123")

        whenever(mockClient.enrollRecoveryCode()).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<RecoveryCodeEnrollmentChallenge, MyAccountException>>(0)
            callback.onSuccess(mockChallenge)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollRecoveryCodeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<RecoveryCodeEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("server_error")
        whenever(exception.getDescription()).thenReturn("Server error")
        whenever(exception.statusCode).thenReturn(500)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.enrollRecoveryCode()).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<RecoveryCodeEnrollmentChallenge, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("server_error"), eq("Server error"), any())
    }
}
