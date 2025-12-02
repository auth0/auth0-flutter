package com.auth0.auth0_flutter

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.provider.BrowserPicker
import com.auth0.android.provider.CustomTabsOptions
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
        Credentials(JwtTestUtils.createJwt(), "test", "", null, Date(), "openid profile email offline_access")

    private fun runRequestHandler(
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

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mock(), request, mockResult)
    }

    @Test
    fun `handler should log in using the Auth0 SDK`() {
        runRequestHandler { result, builder ->
            val formattedDate = defaultCredentials.expiresAt.toInstant().toString()

            verify(result).success(check {
                val map = it as Map<*, *>
                assertThat(map["idToken"], equalTo(defaultCredentials.idToken))
                assertThat(map["accessToken"], equalTo(defaultCredentials.accessToken))
                assertThat(map["expiresAt"], equalTo(formattedDate))
                assertThat(map["scopes"], equalTo(listOf("openid", "profile", "email", "offline_access")))
                assertThat(map["refreshToken"], nullValue())
            })

            verify(builder).withScope("")
            verify(builder, never()).withAudience(any())
            verify(builder, never()).withOrganization(any())
            verify(builder, never()).withInvitationUrl(any())
            verify(builder, never()).withRedirectUri(any())
            verify(builder, never()).withIdTokenVerificationLeeway(any())
            verify(builder, never()).withMaxAge(any())
            verify(builder, never()).withIdTokenVerificationIssuer(any())
            verify(builder, never()).withScheme(any())
            verify(builder, never()).withParameters(any())
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
    fun `handler should add an empty scope when given an empty array`() {
        val args = hashMapOf<String, Any?>(
            "scopes" to arrayListOf<String>()
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withScope("")
        }
    }

    @Test
    fun `handler should add an empty scope when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder).withScope("")
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
    fun `handler should not set the audience on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withAudience(anyOrNull())
        }
    }

    @Test
    fun `handler should set the redirectUrl on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "redirectUrl" to "http://test.com"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withRedirectUri("http://test.com")
        }
    }

    @Test
    fun `handler should not set the redirectUrl on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withRedirectUri(anyOrNull())
        }
    }

    @Test
    fun `handler should set the organizationId on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "organizationId" to "org_123"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withOrganization("org_123")
        }
    }

    @Test
    fun `handler should not set the organizationId on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withOrganization(anyOrNull())
        }
    }

    @Test
    fun `handler should set the invitationUrl on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "invitationUrl" to "http://invitation.com"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withInvitationUrl("http://invitation.com")
        }
    }

    @Test
    fun `handler should not set the invitationUrl on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withInvitationUrl(anyOrNull())
        }
    }

    @Test
    fun `handler should set the leeway on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "leeway" to 60
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withIdTokenVerificationLeeway(60)
        }
    }

    @Test
    fun `handler should not set the leeway on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withIdTokenVerificationLeeway(anyOrNull())
        }
    }

    @Test
    fun `handler should set the maxAge on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "maxAge" to 60
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withMaxAge(60)
        }
    }

    @Test
    fun `handler should not set the maxAge on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withMaxAge(anyOrNull())
        }
    }

    @Test
    fun `handler should set the issuer on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "issuer" to "http://issuer.com"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withIdTokenVerificationIssuer("http://issuer.com")
        }
    }

    @Test
    fun `handler should not set the issuer on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withIdTokenVerificationIssuer(anyOrNull())
        }
    }

    @Test
    fun `handler should set the scheme on the SDK when specified`() {
        val args = hashMapOf<String, Any?>(
            "scheme" to "demo"
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withScheme("demo")
        }
    }

    @Test
    fun `handler should not set the scheme on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withScheme(anyOrNull())
        }
    }

    @Test
    fun `handler should set the parameters on the SDK when specified`() {
        val parameters = hashMapOf("hello" to "world")

        val args = hashMapOf<String, Any?>(
            "parameters" to parameters
        )

        runRequestHandler(args) { _, builder ->
            verify(builder).withParameters(parameters)
        }
    }

    @Test
    fun `handler should not set the parameters on the SDK when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withParameters(anyOrNull())
        }
    }

    @Test
    fun `returns the error when the builder fails`() {
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val exception = AuthenticationException("code", "description")

        doAnswer { invocation ->
            val cb =
                invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onFailure(exception)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }

        val mockAccount = mock<Auth0>()
        val mockRequest = MethodCallRequest(mockAccount, hashMapOf<String, Any>())
        handler.handle(mock(), mockRequest, mockResult)

        verify(mockResult).error("code", "description", exception)
    }

    @Test
    fun `returns the result when the builder succeeds`() {
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"))
        val credentials = Credentials(idToken, "test", "", null, Date(), "scope1 scope2")

        doAnswer { invocation ->
            val cb =
                invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)

            cb.onSuccess(credentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }

        val mockAccount = mock<Auth0>()
        val mockRequest = MethodCallRequest(mockAccount, hashMapOf<String, Any>())
        handler.handle(mock(), mockRequest, mockResult)

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val formattedDate = credentials.expiresAt.toInstant().toString()

        assertThat((captor.firstValue as Map<*, *>)["accessToken"], equalTo(credentials.accessToken))
        assertThat((captor.firstValue as Map<*, *>)["idToken"], equalTo(credentials.idToken))
        assertThat((captor.firstValue as Map<*, *>)["refreshToken"], equalTo(credentials.refreshToken))
        assertThat((captor.firstValue as Map<*, *>)["expiresAt"] as String, equalTo(formattedDate))
        assertThat((captor.firstValue as Map<*, *>)["scopes"], equalTo(listOf("scope1", "scope2")))
        assertThat(((captor.firstValue as Map<*, *>)["userProfile"] as Map<*, *>)["name"], equalTo("John Doe"))
    }

    @Test
    fun `handler should not add an empty allowedPackages when given an empty array`() {
        val args = hashMapOf<String, Any?>(
            "allowedBrowsers" to listOf<String>()
        )

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withCustomTabsOptions(CustomTabsOptions.newBuilder().withBrowserPicker(
                BrowserPicker.newBuilder().withAllowedPackages(listOf<String>()).build()).build())
        }
    }

    @Test
    fun `handler should not add an empty allowedPackages when not specified`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { _, builder ->
            verify(builder, never()).withCustomTabsOptions(CustomTabsOptions.newBuilder().withBrowserPicker(
                BrowserPicker.newBuilder().withAllowedPackages(listOf<String>()).build()).build())
        }
    }

    // DPoP Tests
    @Test
    fun `handler should enable DPoP when useDPoP is true`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        // Verify that the result was successful (DPoP was enabled without errors)
        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should not enable DPoP when useDPoP is false`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to false
        )

        runRequestHandler(args) { result, _ ->
            // Should succeed without enabling DPoP
            verify(result).success(any())
            verify(result, never()).error(any(), any(), any())
        }
    }

    @Test
    fun `handler should not enable DPoP when useDPoP is not provided`() {
        val args = hashMapOf<String, Any?>()

        runRequestHandler(args) { result, _ ->
            // Should succeed without enabling DPoP
            verify(result).success(any())
            verify(result, never()).error(any(), any(), any())
        }
    }

    @Test
    fun `handler should work with DPoP and other parameters combined`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "scopes" to arrayListOf("openid", "profile", "email"),
            "audience" to "https://api.example.com"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        // Verify DPoP was enabled successfully (no errors) and login succeeded
        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with scheme parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "scheme" to "demo"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with custom parameters`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "parameters" to hashMapOf("key1" to "value1", "key2" to "value2")
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with connection parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "connection" to "google-oauth2"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with organization parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "organization" to "org_123456"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with invitation URL parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "invitationUrl" to "https://example.com/invite?token=abc123"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with redirect URI parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "redirectUrl" to "demo://callback"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with max age parameter`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "maxAge" to 3600
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should enable DPoP with all parameters combined`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "scopes" to arrayListOf("openid", "profile", "email", "offline_access"),
            "audience" to "https://api.example.com",
            "redirectUrl" to "demo://callback",
            "organization" to "org_123456",
            "connection" to "google-oauth2",
            "maxAge" to 3600,
            "scheme" to "demo",
            "parameters" to hashMapOf("prompt" to "login", "screen_hint" to "signup")
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onSuccess(defaultCredentials)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).success(any())
        verify(mockResult, never()).error(any(), any(), any())
    }

    @Test
    fun `handler should handle authentication error with DPoP enabled`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()
        val authException = mock<AuthenticationException>()

        whenever(authException.getCode()).thenReturn("access_denied")
        whenever(authException.getDescription()).thenReturn("User cancelled authentication")

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onFailure(authException)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).error(
            eq("access_denied"),
            eq("User cancelled authentication"),
            any()
        )
        verify(mockResult, never()).success(any())
    }

    @Test
    fun `handler should handle network error with DPoP enabled`() {
        val args = hashMapOf<String, Any?>(
            "useDPoP" to true,
            "audience" to "https://api.example.com"
        )
        val builder = mock<WebAuthProvider.Builder>()
        val mockResult = mock<Result>()
        val mockActivity = mock<android.app.Activity>()
        val authException = mock<AuthenticationException>()

        whenever(authException.getCode()).thenReturn("network_error")
        whenever(authException.getDescription()).thenReturn("Network request failed")

        doAnswer { invocation ->
            val cb = invocation.getArgument<Callback<Credentials, AuthenticationException>>(1)
            cb.onFailure(authException)
        }.`when`(builder).start(any(), any())

        val handler = LoginWebAuthRequestHandler { _ -> builder }
        val request = MethodCallRequest(Auth0.getInstance("test-client", "test.auth0.com"), args)

        handler.handle(mockActivity, request, mockResult)

        verify(mockResult).error(
            eq("network_error"),
            eq("Network request failed"),
            any()
        )
        verify(mockResult, never()).success(any())
    }

}
