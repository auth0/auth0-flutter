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
class ClearAllRequestHandlerTest {

    @Test
    fun `should call clearAll with the correct parameters`() {
        val handler = ClearAllRequestHandler()
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

        verify(mockCredentialsManager).clearAll()
    }

    @Test
    fun `should call result success with null because the native API returns void`() {
        val handler = ClearAllRequestHandler()
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

        verify(mockResult).success(isNull())
    }

    @Test
    fun `should call result error when clearAll throws`() {
        val handler = ClearAllRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, mock())

        doThrow(RuntimeException("keystore error"))
            .whenever(mockCredentialsManager).clearAll()

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        )

        verify(mockResult).error(eq("keystore error"), eq("keystore error"), isNull())
        verify(mockResult, never()).success(any())
    }

}
