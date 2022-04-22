package com.auth0.auth0_flutter

import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.WebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "_account" to mapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client",
        ),
        "_userAgent" to mapOf(
            "name" to "auth0-flutter",
            "version" to "1.0.0"
        )
    )

    private fun runCallHandler(
        method: String,
        arguments: HashMap<String, Any?> = defaultArguments,
        handlers: List<WebAuthRequestHandler>,
        onResult: (Result) -> Unit
    ) {
        val handler = Auth0FlutterWebAuthMethodCallHandler(handlers)
        val mockResult = mock<Result>()

        handler.context = mock()

        handler.onMethodCall(MethodCall(method, arguments), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        runCallHandler("random#method", handlers = emptyList()) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should only run the correct handler`() {
        val loginHandlerMock = mock<LoginWebAuthRequestHandler>()
        val logoutHandlerMock = mock<LogoutWebAuthRequestHandler>()

        `when`(loginHandlerMock.method).thenReturn("webAuth#login")
        `when`(logoutHandlerMock.method).thenReturn("webAuth#logout")

        runCallHandler(loginHandlerMock.method, handlers = listOf(loginHandlerMock, logoutHandlerMock)) { _ ->
            verify(loginHandlerMock).handle(any(), any(), any())
            verify(logoutHandlerMock, times(0)).handle(any(), any(), any())
        }
    }
}
