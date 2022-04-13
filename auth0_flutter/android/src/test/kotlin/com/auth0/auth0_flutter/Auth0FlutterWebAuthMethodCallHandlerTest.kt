package com.auth0.auth0_flutter

//import kotlin.test.assertEquals
import android.content.Context
import com.auth0.android.provider.WebAuthProvider
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.*
import org.hamcrest.Matchers
import org.hamcrest.Matchers.*
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {
    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        val handler = Auth0FlutterWebAuthMethodCallHandler()
        val mockResult = mock(Result::class.java)

        handler.context = mock(Context::class.java)
        handler.handlerResolver = { call, request -> null }

        val args = hashMapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client"
        )

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)

        verify(mockResult).notImplemented()
    }

    @Test
    fun `handler should log in using the Auth0 SDK`() {
        val handler = Auth0FlutterWebAuthMethodCallHandler()
        val mockResult = mock(Result::class.java)

        handler.context = mock(Context::class.java)

        handler.handlerResolver = { call, request ->
            val builder = mock(WebAuthProvider.Builder::class.java)
            LoginWebAuthRequestHandler(builder)
        }

        val args = hashMapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client"
        )

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)
    }
}
