package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyString
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ClearApiCredentialsRequestHandlerTest {

    @Test
    fun `should call clearApiCredentials with the provided audience`() {
        val handler = ClearApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>("audience" to "test-audience")
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockCredentialsManager).clearApiCredentials(eq("test-audience"))
    }

    @Test
    fun `should call result success on success`() {
        val handler = ClearApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>("audience" to "test-audience")
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).success(eq(true))
    }

    @Test
    fun `should error when audience is missing`() {
        val handler = ClearApiCredentialsRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).error(eq("UNKNOWN ERROR"), any(), anyOrNull())
        verify(mockCredentialsManager, never()).clearApiCredentials(anyString())
    }
}
