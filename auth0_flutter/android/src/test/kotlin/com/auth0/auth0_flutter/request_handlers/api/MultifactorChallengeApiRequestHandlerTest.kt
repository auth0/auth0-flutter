package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
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
        val options = hashMapOf<String, Any>()
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
    fun `should call multifactorChallenge with the correct parameters`() {
        val options = hashMapOf(
                "mfaToken" to "test-mfaToken",
                "types" to arrayListOf("type-1", "type-2"),
                "authenticatorId" to "test-authenticatorId"
        )
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).multifactorChallenge(any(), any(), any())

        handler.handle(mockApi, request, mockResult)

        verify(mockApi).multifactorChallenge("test-mfaToken", "type-1 type-2", "test-authenticatorId")
        verify(mockBuilder).start(any())
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
                "mfaToken" to "test-mfaToken",
                "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        )
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).multifactorChallenge(any(), anyOrNull(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder).addParameters(
                mapOf(
                        "test" to "test-value",
                        "test2" to "test-value"
                )
        )
    }

    @Test
    fun `should not configure the parameters when not provided`() {
        val options = hashMapOf("mfaToken" to "test-mfaToken")
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)

        doReturn(mockBuilder).`when`(mockApi).multifactorChallenge(any(), anyOrNull(), anyOrNull())
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockBuilder, times(0)).addParameters(any())
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf("mfaToken" to "test-mfaToken")
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val exception =
                AuthenticationException(code = "test-code", description = "test-description")

        doReturn(mockBuilder).`when`(mockApi).multifactorChallenge(any(), anyOrNull(), anyOrNull())
        doAnswer {
            val ob = it.getArgument<Callback<Challenge, AuthenticationException>>(0)
            ob.onFailure(exception)
        }.`when`(mockBuilder).start(any())

        handler.handle(mockApi, request, mockResult)

        verify(mockResult).error(eq("test-code"), eq("test-description"), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf("mfaToken" to "test-mfaToken")
        val handler = MultifactorChallengeApiRequestHandler()
        val mockBuilder = mock<Request<Challenge, AuthenticationException>>()
        val mockApi = mock<AuthenticationAPIClient>()
        val mockAccount = mock<Auth0>()
        val mockResult = mock<Result>()
        val request = MethodCallRequest(account = mockAccount, options)
        val challenge = Challenge("challengeType", "oobCode", "bindingMethod")

        doReturn(mockBuilder).`when`(mockApi).multifactorChallenge(any(), anyOrNull(), anyOrNull())
        doAnswer {
            val ob = it.getArgument<Callback<Challenge, AuthenticationException>>(0)
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
