package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.Request
import com.auth0.android.result.AuthenticatorSelection
import com.auth0.android.result.AuthnParamsPublicKey
import com.auth0.android.result.PasskeyEnrollmentChallenge
import com.auth0.android.result.PubKeyCredParam
import com.auth0.android.result.PasskeyUser
import com.auth0.android.result.RelyingParty
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class EnrollPasskeyChallengeRequestHandlerTest {

    private fun sampleChallenge() = PasskeyEnrollmentChallenge(
        "auth_method_123",
        "session123",
        AuthnParamsPublicKey(
            authenticatorSelection = AuthenticatorSelection(
                residentKey = "required",
                userVerification = "preferred"
            ),
            challenge = "challenge-data",
            pubKeyCredParams = listOf(PubKeyCredParam(alg = -7, type = "public-key")),
            relyingParty = RelyingParty(id = "example.com", name = "Example"),
            timeout = 60000,
            user = PasskeyUser(displayName = "John", id = "user-id", name = "john@example.com")
        )
    )

    @Test
    fun `should call passkeyEnrollmentChallenge on the client`() {
        val handler = EnrollPasskeyChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        whenever(mockClient.passkeyEnrollmentChallenge(anyOrNull(), anyOrNull()))
            .thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).passkeyEnrollmentChallenge(null, null)
    }

    @Test
    fun `should forward userIdentityId and connection`() {
        val handler = EnrollPasskeyChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf("userIdentityId" to "uid", "connection" to "db")
        )

        whenever(mockClient.passkeyEnrollmentChallenge(anyOrNull(), anyOrNull()))
            .thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).passkeyEnrollmentChallenge("uid", "db")
    }

    @Test
    fun `should call result success with challenge map on success`() {
        val handler = EnrollPasskeyChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())

        whenever(mockClient.passkeyEnrollmentChallenge(anyOrNull(), anyOrNull()))
            .thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<PasskeyEnrollmentChallenge, MyAccountException>>(0)
            callback.onSuccess(sampleChallenge())
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollPasskeyChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyEnrollmentChallenge, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, hashMapOf<String, Any>())
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("server_error")
        whenever(exception.getDescription()).thenReturn("Server error")
        whenever(exception.statusCode).thenReturn(500)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.passkeyEnrollmentChallenge(anyOrNull(), anyOrNull()))
            .thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<PasskeyEnrollmentChallenge, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("server_error"), eq("Server error"), any())
    }
}
