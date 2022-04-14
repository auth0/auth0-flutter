package com.auth0.auth0_flutter

//import kotlin.test.assertEquals
import android.content.Context
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.*
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.util.*
import org.hamcrest.MatcherAssert.assertThat
import java.text.SimpleDateFormat

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {
    @Test
    fun `handler should result in 'notImplemented' if no handler`() {
        val handler = Auth0FlutterWebAuthMethodCallHandler()
        val mockResult = mock<Result>()

        handler.context = mock()
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
        val mockResult = mock<Result>()

        handler.context = mock()

        handler.handlerResolver = { call, request ->
            val builder = mock<WebAuthProvider.Builder>()

            doAnswer { invocation ->
                val callback =
                    invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)

                val credentials = Credentials(JwtTestUtils.createJwt(), "test", "", null, Date(), null)

                callback.onSuccess(credentials)

                val sdf =
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

                val formattedDate = sdf.format(credentials.expiresAt)

                verify(mockResult).success(check {
                    val map = it as Map<*, *>
                    assertThat(map["idToken"], equalTo(credentials.idToken))
                    assertThat(map["accessToken"], equalTo(credentials.accessToken))
                    assertThat(map["expiresAt"], equalTo(formattedDate))
                    assertThat(map["scope"], equalTo(credentials.scope))
                    assertThat(map["refreshToken"], nullValue())
                })
            }.`when`(builder).start(any(), any())

            LoginWebAuthRequestHandler(builder)
        }

        val args = hashMapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client"
        )

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)
    }
}
