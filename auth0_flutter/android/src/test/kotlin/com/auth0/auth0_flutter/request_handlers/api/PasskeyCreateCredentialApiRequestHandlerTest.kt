package com.auth0.auth0_flutter.request_handlers.api

import android.content.Context
import android.os.Build
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class PasskeyCreateCredentialApiRequestHandlerTest {

    @Test
    @Config(sdk = [Build.VERSION_CODES.O])
    fun `should error when below Android 9`() {
        val options = hashMapOf<String, Any>(
            "challenge" to mapOf(
                "authParamsPublicKey" to mapOf("challenge" to "c", "rpId" to "r")
            )
        )
        val handler = PasskeyCreateCredentialApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(
            eq("PASSKEY_ERROR"),
            eq("Passkey authentication requires Android 9 or higher"),
            anyOrNull()
        )
    }

    @Test
    @Config(sdk = [Build.VERSION_CODES.P])
    fun `should error when challenge is missing`() {
        val options = hashMapOf<String, Any>()
        val handler = PasskeyCreateCredentialApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(eq("PASSKEY_ERROR"), eq("Missing challenge argument"), anyOrNull())
    }

    @Test
    @Config(sdk = [Build.VERSION_CODES.P])
    fun `should error when authParamsPublicKey is missing`() {
        val options = hashMapOf<String, Any>(
            "challenge" to mapOf("authSession" to "test-auth-session")
        )
        val handler = PasskeyCreateCredentialApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(
            eq("PASSKEY_ERROR"),
            eq("Missing authParamsPublicKey in challenge"),
            anyOrNull()
        )
    }

    @Test
    fun `method name is correct`() {
        val handler = PasskeyCreateCredentialApiRequestHandler()
        assert(handler.method == "auth#passkeyCreateCredential")
    }
}
