package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.callback.Callback
import com.auth0.android.result.SSOCredentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyMap
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GetSSOCredentialsRequestHandlerTest {

    @Test
    fun `should call getSsoCredentials without providing options`() {
        val handler = GetSSOCredentialsRequestHandler()
        val options = hashMapOf<String, Any>()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockCredentialsManager).getSsoCredentials(anyMap(), any())
    }

    @Test
    fun `should pass parameters to getSsoCredentials`() {
        val handler = GetSSOCredentialsRequestHandler()
        val options = hashMapOf(
            "parameters" to mapOf("key" to "value")
        )
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockCredentialsManager).getSsoCredentials(
            eq(mapOf("key" to "value")),
            any()
        )
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf<String, Any>()
        val handler = GetSSOCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()
        `when`(exception.message).thenReturn("test-message")

        doAnswer {
            val cb = it.getArgument<Callback<SSOCredentials, CredentialsManagerException>>(1)
            cb.onFailure(exception)
        }.`when`(mockCredentialsManager).getSsoCredentials(anyMap(), any())

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).error(eq("test-message"), eq("test-message"), any())
    }

    @Test
    fun `should fallback to UNKNOWN ERROR on failure without a message`() {
        val options = hashMapOf<String, Any>()
        val handler = GetSSOCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val exception = mock<CredentialsManagerException>()
        `when`(exception.message).thenReturn(null)

        doAnswer {
            val cb = it.getArgument<Callback<SSOCredentials, CredentialsManagerException>>(1)
            cb.onFailure(exception)
        }.`when`(mockCredentialsManager).getSsoCredentials(anyMap(), any())

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        verify(mockResult).error(eq("UNKNOWN ERROR"), isNull(), any())
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf<String, Any>()
        val handler = GetSSOCredentialsRequestHandler()
        val mockResult = mock<Result>()
        val mockAccount = mock<Auth0>()
        val mockCredentialsManager = mock<SecureCredentialsManager>()
        val request = MethodCallRequest(account = mockAccount, options)

        val mockSSOCredentials = mock<SSOCredentials>()
        `when`(mockSSOCredentials.sessionTransferToken).thenReturn("sso-token")
        `when`(mockSSOCredentials.issuedTokenType).thenReturn("session_transfer")
        `when`(mockSSOCredentials.expiresIn).thenReturn(3600)
        `when`(mockSSOCredentials.idToken).thenReturn("id-token")
        `when`(mockSSOCredentials.refreshToken).thenReturn(null)

        whenever(mockCredentialsManager.getSsoCredentials(anyMap(), any())).thenAnswer {
            val callback = it.getArgument<Callback<SSOCredentials, CredentialsManagerException>>(1)
            callback.onSuccess(mockSSOCredentials)
        }

        handler.handle(mockCredentialsManager, mock(), request, mockResult)

        val captor = argumentCaptor<Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val resultMap = captor.firstValue

        MatcherAssert.assertThat(
            resultMap["sessionTransferToken"],
            CoreMatchers.equalTo("sso-token")
        )
        MatcherAssert.assertThat(
            resultMap["tokenType"],
            CoreMatchers.equalTo("session_transfer")
        )
        MatcherAssert.assertThat(
            resultMap["expiresIn"],
            CoreMatchers.equalTo(3600)
        )
        MatcherAssert.assertThat(
            resultMap["idToken"],
            CoreMatchers.equalTo("id-token")
        )
        MatcherAssert.assertThat(
            resultMap.containsKey("refreshToken"),
            CoreMatchers.equalTo(false)
        )
    }
}
