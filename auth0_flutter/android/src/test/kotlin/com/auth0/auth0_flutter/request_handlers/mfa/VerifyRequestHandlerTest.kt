package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.Auth0
import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaVerifyException
import com.auth0.android.authentication.mfa.MfaVerificationType
import com.auth0.android.callback.Callback
import com.auth0.android.request.Request
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VerifyRequestHandlerTest {

    private fun requestWith(data: Map<String, Any>): MethodCallRequest {
        val map = hashMapOf<String, Any>("mfaToken" to "mfa-token")
        map.putAll(data)
        return MethodCallRequest(account = mock<Auth0>(), map)
    }

    @Test
    fun `should call verify with Otp type`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Credentials, MfaVerifyException>>()

        whenever(mockClient.verify(any())).thenReturn(mockRequest)

        handler.handle(
            mockClient,
            requestWith(mapOf("grantType" to "otp", "otp" to "123456")),
            mockResult
        )

        verify(mockClient).verify(eq(MfaVerificationType.Otp("123456")))
    }

    @Test
    fun `should call verify with Oob type and binding code`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Credentials, MfaVerifyException>>()

        whenever(mockClient.verify(any())).thenReturn(mockRequest)

        handler.handle(
            mockClient,
            requestWith(
                mapOf(
                    "grantType" to "oob",
                    "oobCode" to "oob-code",
                    "bindingCode" to "000111"
                )
            ),
            mockResult
        )

        verify(mockClient).verify(eq(MfaVerificationType.Oob("oob-code", "000111")))
    }

    @Test
    fun `should call verify with RecoveryCode type`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Credentials, MfaVerifyException>>()

        whenever(mockClient.verify(any())).thenReturn(mockRequest)

        handler.handle(
            mockClient,
            requestWith(mapOf("grantType" to "recovery_code", "recoveryCode" to "ABCD")),
            mockResult
        )

        verify(mockClient).verify(eq(MfaVerificationType.RecoveryCode("ABCD")))
    }

    @Test
    fun `should call result success with credentials on success`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Credentials, MfaVerifyException>>()

        val credentials = mock<Credentials>()
        whenever(credentials.accessToken).thenReturn("access-token")
        whenever(credentials.idToken).thenReturn("id-token")
        whenever(credentials.type).thenReturn("Bearer")
        whenever(credentials.scope).thenReturn("openid")
        whenever(credentials.expiresAt).thenReturn(java.util.Date(0))
        val user = mock<com.auth0.android.result.UserProfile>()
        whenever(user.toMap()).thenReturn(mapOf("sub" to "user-id"))
        whenever(credentials.user).thenReturn(user)

        whenever(mockClient.verify(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<Credentials, MfaVerifyException>>(0)
            callback.onSuccess(credentials)
        }.whenever(mockRequest).start(any())

        handler.handle(
            mockClient,
            requestWith(mapOf("grantType" to "otp", "otp" to "123456")),
            mockResult
        )

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()
        val mockRequest = mock<Request<Credentials, MfaVerifyException>>()
        val exception = mock<MfaVerifyException>()
        whenever(exception.getCode()).thenReturn("invalid_grant")
        whenever(exception.getDescription()).thenReturn("Invalid otp code")
        whenever(exception.statusCode).thenReturn(403)

        whenever(mockClient.verify(any())).thenReturn(mockRequest)
        doAnswer {
            val callback = it.getArgument<Callback<Credentials, MfaVerifyException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(
            mockClient,
            requestWith(mapOf("grantType" to "otp", "otp" to "123456")),
            mockResult
        )

        verify(mockResult).error(eq("invalid_grant"), eq("Invalid otp code"), any())
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when grantType is missing`() {
        val handler = VerifyRequestHandler()
        val mockResult = mock<Result>()
        val mockClient = mock<MfaApiClient>()

        handler.handle(mockClient, requestWith(emptyMap()), mockResult)
    }
}
