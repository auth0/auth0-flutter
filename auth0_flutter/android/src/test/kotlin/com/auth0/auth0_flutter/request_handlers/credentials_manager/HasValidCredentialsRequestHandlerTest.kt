package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class HasValidCredentialsRequestHandlerTest {

    @Test
    fun `should call hasValidCredentials with the correct parameters`() {
        val handler = HasValidCredentialsRequestHandler();
        var minTtl: Long = 30;
        val options = hashMapOf(
            "minTtl" to minTtl,
        );
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<CredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        );

        verify(mockCredentialsManager).hasValidCredentials(minTtl);
    }

    @Test
    fun `should call hasValidCredentials without setting minTtl`() {
        val handler = HasValidCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<CredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, mock());

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        );

        verify(mockCredentialsManager).hasValidCredentials();
    }

    @Test
    fun `should call result success on success`() {
        val handler = HasValidCredentialsRequestHandler();
        var minTtl: Long = 30;
        val options = hashMapOf(
            "minTtl" to minTtl,
        );
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<CredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);


        doReturn(true).`when`(mockCredentialsManager).hasValidCredentials(any());

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        );

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        assertThat(captor.firstValue, equalTo(true))

    }
}
