package com.auth0.auth0_flutter

import com.auth0.auth0_flutter.request_handlers.api.ApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.LoginApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.SignupApiRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterAuthMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "domain" to "test.auth0.com",
        "clientId" to "test-client",
        "userAgent" to mapOf(
            "name" to "auth0-flutter",
            "version" to "1.0.0"
        )
    )

    private fun runCallHandler(
        method: String,
        arguments: HashMap<String, Any?> = defaultArguments,
        requestHandlers: List<ApiRequestHandler>,
        onResult: (Result) -> Unit
    ) {
        val handler = Auth0FlutterAuthMethodCallHandler(requestHandlers)
        val mockResult = mock<Result>()

        handler.context = mock()

        handler.onMethodCall(MethodCall(method, arguments), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handlers`() {
        runCallHandler("auth#login", requestHandlers = listOf()) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should result in 'notImplemented' if no matching handler`() {
        val signupHandler = mock<SignupApiRequestHandler>();

        `when`(signupHandler.method).thenReturn("auth#signup");

        runCallHandler("auth#login", requestHandlers = listOf(signupHandler)) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should only run the correct handler`() {
        val loginHandler = mock<LoginApiRequestHandler>();
        val signupHandler = mock<SignupApiRequestHandler>();

        `when`(loginHandler.method).thenReturn("auth#login");
        `when`(signupHandler.method).thenReturn("auth#signup");

        runCallHandler(loginHandler.method, requestHandlers = listOf(loginHandler, signupHandler)) { _ ->
            verify(loginHandler).handle(any(), any(), any())
            verify(signupHandler, times(0)).handle(any(), any(), any())
        }
    }
}
