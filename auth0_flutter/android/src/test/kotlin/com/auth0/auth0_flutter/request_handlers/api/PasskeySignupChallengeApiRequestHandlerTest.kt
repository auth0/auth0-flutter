package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.request.UserData
import com.auth0.android.result.AuthenticatorSelection
import com.auth0.android.result.AuthnParamsPublicKey
import com.auth0.android.result.PasskeyRegistrationChallenge
import com.auth0.android.result.PasskeyUser
import com.auth0.android.result.PubKeyCredParam
import com.auth0.android.result.RelyingParty
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PasskeySignupChallengeApiRequestHandlerTest {
    private fun challenge() = PasskeyRegistrationChallenge(
        authSession = "test-auth-session",
        authParamsPublicKey = AuthnParamsPublicKey(
            authenticatorSelection = AuthenticatorSelection(
                residentKey = "required",
                userVerification = "required"
            ),
            challenge = "test-challenge",
            pubKeyCredParams = listOf(PubKeyCredParam(alg = -7, type = "public-key")),
            relyingParty = RelyingParty(id = "test-rp-id", name = "test-rp"),
            timeout = 60000,
            user = PasskeyUser(
                displayName = "test-display",
                id = "test-user-id",
                name = "test-user-name"
            )
        )
    )

    @Test
    fun `should call signupWithPasskey with the correct parameters`() {
        val options = hashMapOf<String, Any>(
            "email" to "test-email",
            "phoneNumber" to "test-phone",
            "username" to "test-username",
            "name" to "test-name",
            "givenName" to "test-given-name",
            "familyName" to "test-family-name",
            "nickname" to "test-nickname",
            "picture" to "https://www.okta.com",
            "connection" to "test-connection",
            "organization" to "test-org"
        )
        val handler = PasskeySignupChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyRegistrationChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).signupWithPasskey(any(), anyOrNull(), anyOrNull())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).signupWithPasskey(
            argThat {
                this.email == "test-email" &&
                    this.phoneNumber == "test-phone" &&
                    this.userName == "test-username" &&
                    this.name == "test-name" &&
                    this.givenName == "test-given-name" &&
                    this.familyName == "test-family-name" &&
                    this.nickName == "test-nickname" &&
                    this.picture == "https://www.okta.com"
            },
            eq("test-connection"),
            eq("test-org")
        )
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result success with the mapped challenge`() {
        val options = hashMapOf<String, Any>("connection" to "test-connection")
        val handler = PasskeySignupChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyRegistrationChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).signupWithPasskey(any(), anyOrNull(), anyOrNull())
        doAnswer {
            val cb = it.getArgument<Callback<PasskeyRegistrationChallenge, AuthenticationException>>(0)
            cb.onSuccess(challenge())
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())
        val resultMap = captor.firstValue
        assert(resultMap["authSession"] == "test-auth-session")
        val publicKey = resultMap["authParamsPublicKey"] as Map<*, *>
        assert((publicKey["challenge"]) == "test-challenge")
        assert((publicKey["user"] as Map<*, *>)["name"] == "test-user-name")
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>("connection" to "test-connection")
        val handler = PasskeySignupChallengeApiRequestHandler()
        val mockBuilder = mock<Request<PasskeyRegistrationChallenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
            AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockBuilder).`when`(mockApi).signupWithPasskey(any(), anyOrNull(), anyOrNull())
        doAnswer {
            val cb = it.getArgument<Callback<PasskeyRegistrationChallenge, AuthenticationException>>(0)
            cb.onFailure(exception)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }
}
