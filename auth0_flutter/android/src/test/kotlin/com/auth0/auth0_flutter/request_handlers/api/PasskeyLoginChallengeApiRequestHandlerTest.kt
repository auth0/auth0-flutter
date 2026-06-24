package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.AuthParamsPublicKey
import com.auth0.android.result.PasskeyChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PasskeyLoginChallengeApiRequestHandlerTest {
    private fun challenge() = PasskeyChallenge(
        authSession = "test-auth-session",
        authParamsPublicKey = AuthParamsPublicKey(
            challenge = "test-challenge",
            rpId = "test-rp-id",
            timeout = 60000,
            userVerification = "required"
        )
    )

    @Test
    fun `should call passkeyChallenge with the correct parameters`() {
        val options = hashMapOf<String, Any>(
            "connection" to "test-connection",
            "organization" to "test-org"
        )
        val handler = PasskeyLoginChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).passkeyChallenge(any(), any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).passkeyChallenge("test-connection", "test-org")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call passkeyChallenge with null parameters when omitted`() {
        val options = hashMapOf<String, Any>()
        val handler = PasskeyLoginChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).passkeyChallenge(anyOrNull(), anyOrNull())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).passkeyChallenge(null, null)
    }

    @Test
    fun `should call result success with the mapped challenge`() {
        val options = hashMapOf<String, Any>("connection" to "test-connection")
        val handler = PasskeyLoginChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).passkeyChallenge(any(), anyOrNull())
        doAnswer {
            val cb = it.getArgument<Callback<PasskeyChallenge, AuthenticationException>>(0)
            cb.onSuccess(challenge())
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).success(
            mapOf(
                "authSession" to "test-auth-session",
                "authParamsPublicKey" to mapOf(
                    "challenge" to "test-challenge",
                    "rpId" to "test-rp-id",
                    "timeout" to 60000,
                    "userVerification" to "required"
                )
            )
        )
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>("connection" to "test-connection")
        val handler = PasskeyLoginChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockBuilder).`when`(mockApi).passkeyChallenge(any(), anyOrNull())
        doAnswer {
            val cb = it.getArgument<Callback<PasskeyChallenge, AuthenticationException>>(0)
            cb.onFailure(exception)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }
}
