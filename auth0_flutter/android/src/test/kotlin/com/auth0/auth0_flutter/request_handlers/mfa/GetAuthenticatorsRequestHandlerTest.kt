package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.Auth0
import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaListAuthenticatorsException
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.Authenticator
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GetAuthenticatorsRequestHandlerTest {

    @Test
    fun `should call getAuthenticators with factorsAllowed`() {
        val handler = GetAuthenticatorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<List<Authenticator>, MfaListAuthenticatorsException>>()

        val options = hashMapOf<String, Any>(
            "mfaToken" to "mfa-token",
            "factorsAllowed" to listOf("phone")
        )
        val request = MethodCallRequest(account = mockAccount, options)

        whenever(mockClient.getAuthenticators(any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).getAuthenticators(eq(listOf("phone")))
    }

    @Test
    fun `should call result success with authenticators on success`() {
        val handler = GetAuthenticatorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<List<Authenticator>, MfaListAuthenticatorsException>>()
        val options = hashMapOf<String, Any>("mfaToken" to "mfa-token")
        val request = MethodCallRequest(account = mockAccount, options)

        val authenticator = mock<Authenticator>()
        whenever(authenticator.id).thenReturn("sms|1")
        whenever(authenticator.type).thenReturn("phone")
        whenever(authenticator.authenticatorType).thenReturn("oob")
        whenever(authenticator.active).thenReturn(true)
        whenever(authenticator.oobChannel).thenReturn("sms")
        whenever(authenticator.name).thenReturn("****4761")

        whenever(mockClient.getAuthenticators(any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<List<Authenticator>, MfaListAuthenticatorsException>>(0)
            callback.onSuccess(listOf(authenticator))
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = GetAuthenticatorsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<List<Authenticator>, MfaListAuthenticatorsException>>()
        val options = hashMapOf<String, Any>("mfaToken" to "mfa-token")
        val request = MethodCallRequest(account = mockAccount, options)
        val exception = mock<MfaListAuthenticatorsException>()

        whenever(exception.getCode()).thenReturn("invalid_request")
        whenever(exception.getDescription()).thenReturn("Invalid request")
        whenever(exception.statusCode).thenReturn(400)

        whenever(mockClient.getAuthenticators(any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<List<Authenticator>, MfaListAuthenticatorsException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("invalid_request"), eq("Invalid request"), any())
    }
}
