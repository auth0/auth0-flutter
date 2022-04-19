package com.auth0.auth0_flutter

import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.request_handlers.web_auth.LoginWebAuthRequestHandler
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

@RunWith(RobolectricTestRunner::class)
class LoginWebAuthRequestHandlerTest {
    private val defaultCredentials =
        Credentials(JwtTestUtils.createJwt(), "test", "", null, Date(), null)

    fun runRequestHandler(
        args: HashMap<String, Any?> = hashMapOf(),
        credentials: Credentials = defaultCredentials,
        callback: (Result, WebAuthProvider.Builder) -> Unit
    ) {
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()

        doAnswer { invocation ->
            val cb =
                invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)

            cb.onSuccess(credentials)
            callback(mockResult, builder)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler(builder)
        val request = MethodCallRequest("test.auth0.com", "test-client", args)

        handler.handle(mock(), request, mockResult)
    }

    @Test
    fun `handler should log in using the Auth0 SDK`() {
        runRequestHandler { result, _ ->
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

        runRequestHandler(args) { _, builder ->
            verify(builder).withScope("openid profile email")
        }
    }

}
