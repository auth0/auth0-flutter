package com.auth0.auth0_flutter

import com.auth0.auth0_flutter.request_handlers.api.UtilityRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.GetDPoPHeadersApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.ClearDPoPKeyApiRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterDPoPMethodCallHandlerTest {
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
        dpopRequestHandlers: List<UtilityRequestHandler> = emptyList(),
        onResult: (Result) -> Unit
    ) {
        val handler = Auth0FlutterDPoPMethodCallHandler(dpopRequestHandlers)
        val mockResult = mock<Result>()

        handler.onMethodCall(MethodCall(method, arguments), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handlers`() {
        runCallHandler("auth#getDPoPHeaders") { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should result in 'notImplemented' if no matching handler`() {
        val clearHandler = mock<ClearDPoPKeyApiRequestHandler>()

        `when`(clearHandler.method).thenReturn("auth#clearDPoPKey")

        runCallHandler("auth#getDPoPHeaders", dpopRequestHandlers = listOf(clearHandler)) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should only run the correct handler`() {
        val getDPoPHeadersHandler = mock<GetDPoPHeadersApiRequestHandler>()
        val clearDPoPKeyHandler = mock<ClearDPoPKeyApiRequestHandler>()

        `when`(getDPoPHeadersHandler.method).thenReturn("auth#getDPoPHeaders")
        `when`(clearDPoPKeyHandler.method).thenReturn("auth#clearDPoPKey")

        runCallHandler(getDPoPHeadersHandler.method, dpopRequestHandlers = listOf(getDPoPHeadersHandler, clearDPoPKeyHandler)) {
            verify(getDPoPHeadersHandler).handle(any(), any())
            verify(clearDPoPKeyHandler, times(0)).handle(any(), any())
        }
    }
}
