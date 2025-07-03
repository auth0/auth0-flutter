package com.auth0.auth0_flutter

import com.auth0.android.Auth0
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
import android.content.Context

@RunWith(RobolectricTestRunner::class)
class LoginWebAuthRequestHandlerTest {
    private val mockAccount = Auth0("test.auth0.com", "test-client-id")
    private val defaultCredentials =
        Credentials(JwtTestUtils.createJwt(), "test", "", null, Date(), "openid profile email offline_access")
    private val requestArgs = mapOf(
        "scopes" to arrayListOf("openid", "profile", "email"),
        "audience" to "https://myapi/",
        "redirectUrl" to "myapp://callback",
        "organizationId" to "org_123",
        "invitationUrl" to "https://invite.link",
        "allowedPackages" to listOf("com.browser.chrome"),
        "leeway" to 60,
        "maxAge" to 120,
        "issuer" to "https://issuer.auth0.com/",
        "scheme" to "myapp",
        "parameters" to mapOf("screen_hint" to "signup")
    )
    private fun runRequestHandler(
        args: HashMap<String, Any?> = hashMapOf(),
        credentials: Credentials = defaultCredentials,
        callback: (Result, WebAuthProvider.Builder) -> Unit
    ) {
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()

        // Mock the builder methods to allow chaining
        doReturn(builder).`when`(builder).withScope(anyOrNull())
        doReturn(builder).`when`(builder).withAudience(anyOrNull())
        doReturn(builder).`when`(builder).withOrganization(anyOrNull())
        doReturn(builder).`when`(builder).withInvitationUrl(anyOrNull())
        doReturn(builder).`when`(builder).withRedirectUri(anyOrNull())
        doReturn(builder).`when`(builder).withIdTokenVerificationLeeway(anyOrNull())
        doReturn(builder).`when`(builder).withMaxAge(anyOrNull())
        doReturn(builder).`when`(builder).withIdTokenVerificationIssuer(anyOrNull())
        doReturn(builder).`when`(builder).withScheme(anyOrNull())
        doReturn(builder).`when`(builder).withParameters(anyOrNull())


        doAnswer { invocation ->
            val cb =
                invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)

            cb.onSuccess(credentials)
            callback(mockResult, builder)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { builder }
        val request = MethodCallRequest(mockAccount, args)

        handler.handle(mockContext, request, mockResult)
    }

    @Test
    fun `handler should log in and set default issuer`() {
        runRequestHandler { result, builder ->
            val sdf =
                SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")

            val formattedDate = sdf.format(defaultCredentials.expiresAt)

            verify(result).success(check {
                val map = it as Map<*, *>
                assertThat(map["idToken"], equalTo(defaultCredentials.idToken))
                assertThat(map["accessToken"], equalTo(defaultCredentials.accessToken))
                assertThat(map["expiresAt"], equalTo(formattedDate))
                assertThat(map["scopes"], equalTo(listOf("openid", "profile", "email", "offline_access")))
                assertThat(map["refreshToken"], nullValue())
            })

            // Verify default issuer is set
            verify(builder).withIdTokenVerificationIssuer(mockAccount.getDomainUrl())
        }
    }

    @Test
    fun `handler should request scopes from the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "scopes" to arrayListOf("openid", "profile", "email", "offline_access")
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withScope("openid profile email offline_access")
        }
    }

    @Test
    fun `handler should set the audience on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "audience" to "test"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withAudience("test")
        }
    }

    @Test
    fun `handler should override the default issuer on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "issuer" to "http://custom-issuer.com"
        )

        runRequestHandler(args) { _, builder ->
            val inOrder = inOrder(builder)
            inOrder.verify(builder).withIdTokenVerificationIssuer(mockAccount.getDomainUrl())
            inOrder.verify(builder).withIdTokenVerificationIssuer("http://custom-issuer.com")
        }
    }

    @Test
    fun `returns the error when the builder fails`() {
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val exception = AuthenticationException("code", "description")
        val mockContext = mock<Context>()

        doAnswer { invocation ->
            val cb =
                invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onFailure(exception)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { builder }
        val request = MethodCallRequest(mockAccount, hashMapOf<String, Any?>())

        handler.handle(mockContext, request, mockResult)

        verify(mockResult).error("code", "description", exception)
    }
}
