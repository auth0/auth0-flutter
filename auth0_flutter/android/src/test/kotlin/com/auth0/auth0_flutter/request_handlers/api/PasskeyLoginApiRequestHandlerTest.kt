package com.auth0.auth0_flutter.request_handlers.api

import android.content.Context
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.AuthenticationRequest
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.JwtTestUtils
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner
import java.util.*

@RunWith(RobolectricTestRunner::class)
class PasskeyLoginApiRequestHandlerTest {
    private fun challengeMap() = mapOf(
        "authSession" to "test-auth-session",
        "authParamsPublicKey" to mapOf(
            "challenge" to "test-challenge",
            "rpId" to "test-rp-id"
        )
    )

    private fun credentialMap() = mapOf(
        "id" to "test-id",
        "rawId" to "test-raw-id",
        "type" to "public-key",
        "authenticatorAttachment" to "platform",
        "response" to mapOf(
            "clientDataJSON" to "test-client-data",
            "authenticatorData" to "test-authenticator-data",
            "signature" to "test-signature",
            "userHandle" to "test-user-handle"
        )
    )

    @Test
    fun `should error when challenge is missing`() {
        val options = hashMapOf<String, Any>("credential" to credentialMap())
        val handler = PasskeyLoginApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(
            eq("a0.passkey.invalid_request"),
            eq("Missing challenge argument"),
            anyOrNull()
        )
    }

    @Test
    fun `should error when authSession is missing`() {
        val options = hashMapOf<String, Any>(
            "challenge" to mapOf(
                "authParamsPublicKey" to mapOf("challenge" to "c", "rpId" to "r")
            ),
            "credential" to credentialMap()
        )
        val handler = PasskeyLoginApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(
            eq("a0.passkey.invalid_request"),
            eq("Missing authSession in challenge"),
            anyOrNull()
        )
    }

    @Test
    fun `should error when credential is missing`() {
        val options = hashMapOf<String, Any>("challenge" to challengeMap())
        val handler = PasskeyLoginApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(
            eq("a0.passkey.invalid_request"),
            eq("Missing credential argument"),
            anyOrNull()
        )
    }

    @Test
    fun `should call signinWithPasskey and configure scope, audience and parameters`() {
        val options = hashMapOf<String, Any>(
            "challenge" to challengeMap(),
            "credential" to credentialMap(),
            "connection" to "test-connection",
            "organization" to "test-org",
            "audience" to "test-audience",
            "scopes" to arrayListOf("openid", "profile"),
            "parameters" to mapOf("test" to "test-value")
        )
        val handler = PasskeyLoginApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi)
            .signinWithPasskey(any<String>(), any<String>(), anyOrNull(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).validateClaims()
        doReturn(mockBuilder).`when`(mockBuilder).setScope(any())
        doReturn(mockBuilder).`when`(mockBuilder).setAudience(any())
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any())

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockApi).signinWithPasskey(
            eq("test-auth-session"),
            any<String>(),
            eq("test-connection"),
            eq("test-org")
        )
        verify(mockBuilder).validateClaims()
        verify(mockBuilder).setScope("openid profile")
        verify(mockBuilder).setAudience("test-audience")
        verify(mockBuilder).addParameters(mapOf("test" to "test-value"))
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>(
            "challenge" to challengeMap(),
            "credential" to credentialMap()
        )
        val handler = PasskeyLoginApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockBuilder).`when`(mockApi)
            .signinWithPasskey(any<String>(), any<String>(), anyOrNull(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).validateClaims()
        doAnswer {
            val cb = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            cb.onFailure(exception)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult, mockContext, null)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }

    @Test
    fun `should call result success with credentials on success`() {
        val options = hashMapOf<String, Any>(
            "challenge" to challengeMap(),
            "credential" to credentialMap()
        )
        val handler = PasskeyLoginApiRequestHandler()
        val mockBuilder = mock<AuthenticationRequest>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val mockContext = mock<Context>()
        val request = MethodCallRequest(account = mockAccount, options)

        val credentials = Credentials(
            JwtTestUtils.createJwt(),
            "test-access-token",
            "Bearer",
            "test-refresh-token",
            Date(),
            "openid profile"
        )

        doReturn(mockBuilder).`when`(mockApi)
            .signinWithPasskey(any<String>(), any<String>(), anyOrNull(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).validateClaims()
        doAnswer {
            val cb = it.getArgument<Callback<Credentials, AuthenticationException>>(0)
            cb.onSuccess(credentials)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult, mockContext, null)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())
        val resultMap = captor.firstValue
        assertThat(resultMap["accessToken"] as String, equalTo("test-access-token"))
        assertThat(resultMap["tokenType"] as String, equalTo("Bearer"))
        assertThat(resultMap["refreshToken"] as String, equalTo("test-refresh-token"))
        assertThat(resultMap["scopes"], equalTo(listOf("openid", "profile")))
    }
}
