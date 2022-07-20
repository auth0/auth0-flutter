package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.SecureCredentialsManager

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ClearCredentialsRequestHandlerTest {

    @Test
    fun `should call clearCredentials with the correct parameters`() {
        val handler = ClearCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, mock())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockCredentialsManager).clearCredentials()
    }

    @Test
    fun `should call result success on success`() {
        val handler = ClearCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, mock())

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        val captor = argumentCaptor<Boolean>()
        verify(mockResult).success(captor.capture())

        assert(captor.firstValue)
    }

}
