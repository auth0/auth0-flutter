package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.Auth0
import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaChallengeException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.Challenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChallengeRequestHandlerTest {

    @Test
    fun `should call challenge with authenticatorId`() {
        val handler = ChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Challenge, MfaChallengeException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "mfaToken" to "mfa-token",
                "authenticatorId" to "sms|dev_1"
            )
        )

        whenever(mockClient.challenge(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).challenge(eq("sms|dev_1"))
    }

    @Test
    fun `should call result success with challenge on success`() {
        val handler = ChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Challenge, MfaChallengeException>>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "mfaToken" to "mfa-token",
                "authenticatorId" to "sms|dev_1"
            )
        )

        val challenge = mock<Challenge>()
        whenever(challenge.challengeType).thenReturn("oob")
        whenever(challenge.oobCode).thenReturn("oob-code")
        whenever(challenge.bindingMethod).thenReturn("prompt")

        whenever(mockClient.challenge(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<Challenge, MfaChallengeException>>(0)
            callback.onSuccess(challenge)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when authenticatorId is missing`() {
        val handler = ChallengeRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("mfaToken" to "mfa-token")
        )

        handler.handle(mockClient, request, mockResult)
    }
}
