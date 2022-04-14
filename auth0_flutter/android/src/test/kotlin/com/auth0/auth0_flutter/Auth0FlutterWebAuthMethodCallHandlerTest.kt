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

    private val defaultCredentials =
        Credentials(JwtTestUtils.createJwt(), "test", "", null, Date(), null)

    private fun runCallHandler(
        arguments: HashMap<String, Any?>? = null,
        resolver: (MethodCall, MethodCallRequest) -> WebAuthRequestHandler? = createResolver(defaultCredentials),
        onResult: (Result, WebAuthRequestHandler?) -> Unit
    ) {
        val handler = Auth0FlutterWebAuthMethodCallHandler()
        val mockResult = mock<Result>()

        handler.context = mock()
        handler.handlerResolver = resolver

        val args = arguments ?: defaultArguments

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)
        onResult(mockResult, handler.resolvedHandler)
    }

    private fun createResolver(credentials: Credentials): (MethodCall, MethodCallRequest) -> WebAuthRequestHandler? {
        return { _, _ ->
            val builder = mock<WebAuthProvider.Builder>()

            doAnswer { invocation ->
                val callback =
                    invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)

                callback.onSuccess(credentials)
            }.`when`(builder).start(any(), any())

            LoginWebAuthRequestHandler(builder)
        }
    }

    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        runCallHandler(null, { _, _ -> null }) { result, _ ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should log in using the Auth0 SDK`() {
        runCallHandler { result, _ ->
            val sdf =
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

            val formattedDate = sdf.format(defaultCredentials.expiresAt)

            verify(result).success(check {
                val map = it as Map<*, *>
                assertThat(map["idToken"], equalTo(defaultCredentials.idToken))
                assertThat(map["accessToken"], equalTo(defaultCredentials.accessToken))
                assertThat(map["expiresAt"], equalTo(formattedDate))
                assertThat(map["scope"], equalTo(defaultCredentials.scope))
                assertThat(map["refreshToken"], nullValue())
            })
        }
    }

    @Test
    fun `handler should request scopes from the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "scopes" to arrayListOf("openid", "profile", "email")
        )

        args.putAll(defaultArguments)

        runCallHandler(args) { _, handler ->
            if (handler is LoginWebAuthRequestHandler) {
                verify(handler.builder).withScope("openid profile email")
            } else fail("Expected LoginWebAuthRequestHandler")
        }
    }
}
