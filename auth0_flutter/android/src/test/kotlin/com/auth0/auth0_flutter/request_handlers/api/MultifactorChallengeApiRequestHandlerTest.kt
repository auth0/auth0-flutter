package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaChallengeException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.Challenge

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MultifactorChallengeApiRequestHandlerTest {
    @Test
    fun `should throw when missing mfaToken`() {
        val options = hashMapOf<String, Any>("authenticatorId" to "test-authenticatorId")
        val handler = MultifactorChallengeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockApi, request, mockResult)
        }

        assertThat(
                exception.message,
                equalTo("Required property 'mfaToken' is not provided.")
        )
    }

    @Test
    fun `should throw when missing authenticatorId`() {
        val options = hashMapOf<String, Any>("mfaToken" to "test-mfaToken")
        val handler = MultifactorChallengeApiRequestHandler()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockApi, request, mockResult)
        }

        assertThat(
                exception.message,
                equalTo("Required property 'authenticatorId' is not provided.")
        )
    }

    @Test
    fun `should call mfaClient challenge with the correct parameters`() {
        val options = hashMapOf(
                "mfaToken" to "test-mfaToken",
                "authenticatorId" to "test-authenticatorId"
        )
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, MfaChallengeException>>()
        val mockMfaClient = mock<MfaApiClient>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockMfaClient).`when`(mockApi).mfaClient(any())
        doReturn(mockBuilder).`when`(mockMfaClient).challenge(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).mfaClient("test-mfaToken")
        verify(mockMfaClient).challenge("test-authenticatorId")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
                "mfaToken" to "test-mfaToken",
                "authenticatorId" to "test-authenticatorId"
        )
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, MfaChallengeException>>()
        val mockMfaClient = mock<MfaApiClient>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MfaChallengeException>()
        whenever(exception.getCode()).thenReturn("test-code")
        whenever(exception.getDescription()).thenReturn("test-description")

        doReturn(mockMfaClient).`when`(mockApi).mfaClient(any())
        doReturn(mockBuilder).`when`(mockMfaClient).challenge(any())
        doAnswer {
            val ob = it.getArgument<Callback<Challenge, MfaChallengeException>>(0)
            ob.onFailure(exception)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf(
                "mfaToken" to "test-mfaToken",
                "authenticatorId" to "test-authenticatorId"
        )
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, MfaChallengeException>>()
        val mockMfaClient = mock<MfaApiClient>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val challenge = Challenge("challengeType", "oobCode", "bindingMethod")

        doReturn(mockMfaClient).`when`(mockApi).mfaClient(any())
        doReturn(mockBuilder).`when`(mockMfaClient).challenge(any())
        doAnswer {
            val ob = it.getArgument<Callback<Challenge, MfaChallengeException>>(0)
            ob.onSuccess(challenge)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        assertThat(
                (captor.firstValue as Map<*, *>)["challengeType"],
                equalTo(challenge.challengeType)
        )
        assertThat(
                (captor.firstValue as Map<*, *>)["oobCode"],
                equalTo(challenge.oobCode)
        )
        assertThat(
                (captor.firstValue as Map<*, *>)["bindingMethod"],
                equalTo(challenge.bindingMethod)
        )
    }
}
