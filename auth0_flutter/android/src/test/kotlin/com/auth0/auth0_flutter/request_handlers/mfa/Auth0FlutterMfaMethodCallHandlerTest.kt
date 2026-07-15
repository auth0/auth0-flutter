package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.auth0_flutter.Auth0FlutterMfaMethodCallHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterMfaMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "_account" to mapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client",
        ),
        "_userAgent" to mapOf(
            "name" to "auth0-flutter",
            "version" to "1.0.0"
        ),
        "mfaToken" to "test-mfa-token"
    )

    @Test
    fun `handler should result in notImplemented if no matching handler`() {
        val handler = Auth0FlutterMfaMethodCallHandler(emptyList())
        val mockResult = mock<Result>()

        handler.onMethodCall(MethodCall("mfa#unknown", defaultArguments), mockResult)

        verify(mockResult).notImplemented()
    }

    @Test
    fun `handler should call the correct handler when matched`() {
        val mockRequestHandler = mock<MfaRequestHandler>()
        `when`(mockRequestHandler.method).thenReturn("mfa#getAuthenticators")

        val handler = Auth0FlutterMfaMethodCallHandler(listOf(mockRequestHandler))
        val mockResult = mock<Result>()

        handler.onMethodCall(
            MethodCall("mfa#getAuthenticators", defaultArguments),
            mockResult
        )

        verify(mockRequestHandler).handle(any(), any(), eq(mockResult))
    }

    @Test
    fun `handler should not call non-matching handlers`() {
        val getAuthenticatorsHandler = mock<MfaRequestHandler>()
        val challengeHandler = mock<MfaRequestHandler>()

        `when`(getAuthenticatorsHandler.method).thenReturn("mfa#getAuthenticators")
        `when`(challengeHandler.method).thenReturn("mfa#challenge")

        val handler = Auth0FlutterMfaMethodCallHandler(
            listOf(getAuthenticatorsHandler, challengeHandler)
        )
        val mockResult = mock<Result>()

        handler.onMethodCall(
            MethodCall("mfa#getAuthenticators", defaultArguments),
            mockResult
        )

        verify(getAuthenticatorsHandler).handle(any(), any(), eq(mockResult))
        verify(challengeHandler, times(0)).handle(any(), any(), any())
    }
}
