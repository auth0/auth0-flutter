package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.request.PublicKeyCredentials
import com.auth0.android.request.Request
import com.auth0.android.result.PasskeyAuthenticationMethod
import com.auth0.android.result.PasskeyEnrollmentChallenge
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
class EnrollPasskeyRequestHandlerTest {

    private fun challengeMap() = hashMapOf(
        "authenticationMethodId" to "auth_method_123",
        "authSession" to "session123",
        "authParamsPublicKey" to mapOf(
            "authenticatorSelection" to mapOf(
                "residentKey" to "required",
                "userVerification" to "preferred"
            ),
            "challenge" to "challenge-data",
            "pubKeyCredParams" to listOf(mapOf("alg" to -7.0, "type" to "public-key")),
            "rp" to mapOf("id" to "example.com", "name" to "Example"),
            "timeout" to 60000.0,
            "user" to mapOf(
                "displayName" to "John",
                "id" to "user-id",
                "name" to "john@example.com"
            )
        )
    )

    private fun credentialMap() = hashMapOf(
        "id" to "credential-id",
        "rawId" to "raw-credential-id",
        "type" to "public-key",
        "authenticatorAttachment" to "platform",
        "response" to mapOf(
            "clientDataJSON" to "client-data",
            "attestationObject" to "attestation"
        ),
        "clientExtensionResults" to mapOf("credProps" to mapOf("rk" to true))
    )

    private fun fullData() = hashMapOf<String, Any>(
        "challenge" to challengeMap(),
        "credential" to credentialMap()
    )

    @Test
    fun `should call enroll on the client`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyAuthenticationMethod, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, fullData())

        whenever(mockClient.enroll(any(), any())).thenReturn(mockRequest)

        handler.handle(mockClient, request, mockResult)

        verify(mockClient).enroll(any<PublicKeyCredentials>(), any<PasskeyEnrollmentChallenge>())
    }

    @Test
    fun `should call result success with method map on success`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyAuthenticationMethod, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, fullData())

        val method = PasskeyAuthenticationMethod(
            id = "passkey|123",
            type = "passkey",
            createdAt = "2024-01-01T00:00:00.000Z",
            usage = listOf("mfa"),
            credentialBackedUp = true,
            credentialDeviceType = "multi_device",
            identityUserId = "user-id",
            keyId = "key-id",
            publicKey = "public-key",
            transports = listOf("internal"),
            userAgent = "agent",
            userHandle = "handle",
            aaguid = "aaguid",
            relyingPartyId = "example.com"
        )

        whenever(mockClient.enroll(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<PasskeyAuthenticationMethod, MyAccountException>>(0)
            callback.onSuccess(method)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).success(any())
    }

    @Test
    fun `should call result error on failure`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val mockRequest = mock<Request<PasskeyAuthenticationMethod, MyAccountException>>()
        val request = MethodCallRequest(account = mockAccount, fullData())
        val exception = mock<MyAccountException>()

        whenever(exception.getCode()).thenReturn("server_error")
        whenever(exception.getDescription()).thenReturn("Server error")
        whenever(exception.statusCode).thenReturn(500)
        whenever(exception.isNetworkError).thenReturn(false)

        whenever(mockClient.enroll(any(), any())).thenReturn(mockRequest)
        doAnswer {
            val callback =
                it.getArgument<Callback<PasskeyAuthenticationMethod, MyAccountException>>(0)
            callback.onFailure(exception)
        }.whenever(mockRequest).start(any())

        handler.handle(mockClient, request, mockResult)

        verify(mockResult).error(eq("server_error"), eq("Server error"), any())
    }

    @Test
    fun `should throw when challenge is not a map`() {
        // assertHasProperties fires first because tryGetByKey returns null for a
        // non-Map value; the message still identifies the bad field.
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "challenge" to "not-a-map",
                "credential" to credentialMap()
            )
        )

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockClient, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'challenge.authSession' is not provided.")
        )
    }

    @Test
    fun `should throw when credential is not a map`() {
        // assertHasProperties fires first because tryGetByKey returns null for a
        // non-Map value; the message identifies the first missing nested field.
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "challenge" to challengeMap(),
                "credential" to "not-a-map"
            )
        )

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockClient, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credential.id' is not provided.")
        )
    }

    @Test
    fun `should throw when authenticationMethodId is not a string`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val challenge = challengeMap()
        challenge["authenticationMethodId"] = 42
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "challenge" to challenge,
                "credential" to credentialMap()
            )
        )

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockClient, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'challenge.authenticationMethodId' must be a string.")
        )
    }

    @Test
    fun `should throw when authSession is not a string`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val challenge = challengeMap()
        challenge["authSession"] = 42
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "challenge" to challenge,
                "credential" to credentialMap()
            )
        )

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockClient, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'challenge.authSession' must be a string.")
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun `should throw when challenge is missing`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>("credential" to credentialMap())
        )

        handler.handle(mockClient, request, mockResult)
    }

    @Test
    fun `should throw when required credential response field is missing`() {
        val handler = EnrollPasskeyRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockClient = mock<MyAccountAPIClient>()
        val credential = credentialMap()
        credential["response"] = mapOf(
            "clientDataJSON" to "client-data"
        )
        val request = MethodCallRequest(
            account = mockAccount,
            hashMapOf<String, Any>(
                "challenge" to challengeMap(),
                "credential" to credential
            )
        )

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(mockClient, request, mockResult)
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credential.response.attestationObject' is not provided.")
        )
    }
}
