package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.WebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert.fail
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "domain" to "test.auth0.com",
        "clientId" to "test-client"
    )

    private fun runCallHandler(
        arguments: HashMap<String, Any?>? = null,
        resolver: (MethodCall, MethodCallRequest) -> WebAuthRequestHandler?,
        onResult: (Result) -> Unit
    ) {
        val handler = Auth0FlutterWebAuthMethodCallHandler(resolver)
        val mockResult = mock<Result>()

        handler.context = mock()

        val args = arguments ?: defaultArguments

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        val resolver = { _: MethodCall, _: MethodCallRequest -> null }
        runCallHandler(null, resolver) { result ->
            verify(result).notImplemented()
        }
    }
}
