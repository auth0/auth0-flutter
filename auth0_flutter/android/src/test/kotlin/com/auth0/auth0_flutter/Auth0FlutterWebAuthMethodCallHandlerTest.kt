package com.auth0.auth0_flutter

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.WebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "domain" to "test.auth0.com",
        "clientId" to "test-client"
    )

    private fun runCallHandler(
        method: String,
        arguments: HashMap<String, Any?> = defaultArguments,
        resolver: (MethodCall, MethodCallRequest) -> WebAuthRequestHandler?,
        onResult: (Result) -> Unit
    ) {
        val handler = Auth0FlutterWebAuthMethodCallHandler(resolver)
        val mockResult = mock<Result>()

        handler.context = mock()

        handler.onMethodCall(MethodCall(method, arguments), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        runCallHandler("random#method", resolver = { _, _ -> null}) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should run the web auth login handler`() {
        val handlerMock = mock<LoginWebAuthRequestHandler>()

        val resolver = { call: MethodCall, request: MethodCallRequest ->
            when(call.method) {
                WEBAUTH_LOGIN_METHOD -> handlerMock
                else -> null
            }
        }

        runCallHandler(WEBAUTH_LOGIN_METHOD, resolver = resolver) { _ ->
            verify(handlerMock).handle(any(), any(), any())
        }
    }

    @Test
    fun `handler should run the web auth logout handler`() {
        val handlerMock = mock<LogoutWebAuthRequestHandler>()

        val resolver = { call: MethodCall, request: MethodCallRequest ->
            when(call.method) {
                WEBAUTH_LOGOUT_METHOD -> handlerMock
                else -> null
            }
        }

        runCallHandler(WEBAUTH_LOGOUT_METHOD, resolver = resolver) { _ ->
            verify(handlerMock).handle(any(), any(), any())
        }
    }
}
