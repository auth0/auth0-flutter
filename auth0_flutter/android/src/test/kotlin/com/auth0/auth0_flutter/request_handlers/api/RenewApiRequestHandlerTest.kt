package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.callback.Callback
import com.auth0.android.request.AuthenticationRequest
import com.auth0.android.request.Request
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.JwtTestUtils

import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.*
import org.mockito.stubbing.Answer
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*

@RunWith(RobolectricTestRunner::class)
class RenewApiRequestHandlerTest {
    @Test
    fun `should throw when missing refreshToken`() {
        val options = hashMapOf<String, Any>();
        val handler = RenewApiRequestHandler();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockApi,
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'refreshToken' is not provided.")
        );
    }

    @Test
    fun `should call renewAuth with the correct parameters`() {
        val options = hashMapOf(
            "refreshToken" to "test-token"
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockApi).renewAuth("test-token");
        verify(mockBuilder).start(any());
    }

    @Test
    fun `should configure the scopes when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
            "scopes" to arrayListOf("scope1", "scope2")
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameter(any(), any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockBuilder).addParameter("scope", "scope1 scope2");
    }

    @Test
    fun `should not configure the scopes when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameter(any(), any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockBuilder, times(0)).addParameter(any(), any());
    }

    @Test
    fun `should configure the parameters when provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
            "parameters" to mapOf("test" to "test-value", "test2" to "test-value")
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockBuilder).addParameters(
            mapOf(
                "test" to "test-value",
                "test2" to "test-value"
            )
        );
    }

    @Test
    fun `should not configure the parameters when not provided`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockBuilder, times(0)).addParameters(any());
    }

    @Test
    fun `should call result error on failure`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);
        val exception =
            AuthenticationException(code = "test-code", description = "test-description");

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any());
        doAnswer {
            val ob = it.getArgument<Callback<Credentials, AuthenticationException>>(0);
            ob.onFailure(exception);
        }.`when`(mockBuilder).start(any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        verify(mockResult).error(eq("test-code"), eq("test-description"), any());
    }

    @Test
    fun `should call result success on success`() {
        val options = hashMapOf(
            "refreshToken" to "test-token",
        );
        val handler = RenewApiRequestHandler();
        val mockBuilder = mock<Request<Credentials, AuthenticationException>>();
        val mockApi = mock<AuthenticationAPIClient>();
        val mockAccount = mock<Auth0>();
        val mockResult = mock<Result>();
        val request = MethodCallRequest(account = mockAccount, options);
        val idToken = JwtTestUtils.createJwt(claims = mapOf("name" to "John Doe"));
        val credentials = Credentials(idToken, "test", "", null, Date(), "scope1 scope2")

        doReturn(mockBuilder).`when`(mockApi).renewAuth(any());
        doReturn(mockBuilder).`when`(mockBuilder).addParameters(any());
        doAnswer {
            val ob = it.getArgument<Callback<Credentials, AuthenticationException>>(0);
            ob.onSuccess(credentials);
        }.`when`(mockBuilder).start(any());

        handler.handle(
            mockApi,
            request,
            mockResult
        );

        val captor = argumentCaptor<() -> Map<String, *>>()
        verify(mockResult).success(captor.capture())

        val sdf =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.getDefault())

        val formattedDate = sdf.format(credentials.expiresAt)

        assertThat(
            (captor.firstValue as Map<String, *>)["accessToken"],
            equalTo(credentials.accessToken)
        )
        assertThat((captor.firstValue as Map<String, *>)["idToken"], equalTo(credentials.idToken))
        assertThat(
            (captor.firstValue as Map<String, *>)["refreshToken"],
            equalTo(credentials.refreshToken)
        )
        assertThat(
            (captor.firstValue as Map<String, *>)["expiresAt"] as String,
            equalTo(formattedDate)
        )
        assertThat(
            (captor.firstValue as Map<String, *>)["scopes"],
            equalTo(listOf("scope1", "scope2"))
        )
        assertThat(
            ((captor.firstValue as Map<String, *>)["userProfile"] as Map<String, Any>)["name"],
            equalTo("John Doe")
        )
    }
}
