package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import com.auth0.auth0_flutter.request_handlers.web_auth.LogoutWebAuthRequestHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.CoreMatchers.nullValue
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

@RunWith(RobolectricTestRunner::class)
class LogoutWebAuthRequestHandlerTest {
    fun runHandler(args: HashMap<String, Any?> = hashMapOf(), resultCallback: (Result, WebAuthProvider.LogoutBuilder) -> Unit) {
        val mockBuilder = mock<WebAuthProvider.LogoutBuilder>()
        val mockResult = mock<Result>()
        val handler = LogoutWebAuthRequestHandler(mockBuilder)

        doAnswer { invocation ->
            val callback = invocation.getArgument<Callback<Void?, AuthenticationException>>(1)

            callback.onSuccess(null)
            resultCallback(mockResult, mockBuilder)
        }.`when`(mockBuilder).start(any(), any())

        handler.handle(mock(), MethodCallRequest("test-domain", "test-client", args), mockResult)
    }

    @Test
    fun `handler calls success when complete`() {
        runHandler { result, _ ->
            verify(result).success(null)
        }
    }

    @Test
    fun `handler adds scheme when specified in the arguments`() {
        val args = hashMapOf<String, Any?>("scheme" to "demo")

        runHandler(args) { _, builder ->
            verify(builder).withScheme("demo")
        }
    }

    @Test
    fun `handler adds returnTo when specified in the arguments`() {
       val args = hashMapOf<String, Any?>("returnTo" to "http://return.to")

       runHandler(args) { _, builder ->
           verify(builder).withReturnToUrl("http://return.to")
       }
    }

    @Test
    fun `handler returns an error when the builder fails`() {
        val mockBuilder = mock<WebAuthProvider.LogoutBuilder>()
        val mockResult = mock<Result>()
        val handler = LogoutWebAuthRequestHandler(mockBuilder)

        doAnswer { invocation ->
            val callback = invocation.getArgument<Callback<Void?, AuthenticationException>>(1)
            val exception = AuthenticationException("code", "description")

            callback.onFailure(exception)
            verify(mockResult).error("code", "description", exception)
        }.`when`(mockBuilder).start(any(), any())

        handler.handle(mock(), MethodCallRequest("test-domain", "test-client", mock()), mockResult)
    }
}
