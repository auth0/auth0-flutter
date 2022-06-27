package com.auth0.auth0_flutter.request_handlers.credentials_manager

import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.equalTo
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.robolectric.RobolectricTestRunner
import java.text.SimpleDateFormat
import java.util.*

@RunWith(RobolectricTestRunner::class)
class SaveCredentialsRequestHandlerTest {

    @Test
    fun `should throw when missing credentials`() {
        val options =
            hashMapOf<String, Any>();
        val handler = SaveCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockCredentialsManager,
                mock(),
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credentials' is not provided.")
        );
    }

    @Test
    fun `should throw when missing credentials accessToken`() {
        val options =
            hashMapOf<String, Any>("credentials" to hashMapOf(
                "idToken" to "test-id-token",
                "tokenType" to "Bearer",
                "expiresAt" to "2022-01-01"
            ));
        val handler = SaveCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockCredentialsManager,
                mock(),
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credentials.accessToken' is not provided.")
        );
    }

    @Test
    fun `should throw when missing credentials idToken`() {
        val options =
            hashMapOf<String, Any>("credentials" to hashMapOf(
                "accessToken" to "test-access-token",
                "tokenType" to "Bearer",
                "expiresAt" to "2022-01-01"
            ));
        val handler = SaveCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockCredentialsManager,
                mock(),
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credentials.idToken' is not provided.")
        );
    }

    @Test
    fun `should throw when missing credentials type`() {
        val options =
            hashMapOf<String, Any>("credentials" to hashMapOf(
                "accessToken" to "test-access-token",
                "idToken" to "test-id-token",
                "expiresAt" to "2022-01-01"
            ));
        val handler = SaveCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockCredentialsManager,
                mock(),
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credentials.tokenType' is not provided.")
        );
    }

    @Test
    fun `should throw when missing credentials expiresAt`() {
        val options =
            hashMapOf<String, Any>("credentials" to hashMapOf(
                "accessToken" to "test-access-token",
                "idToken" to "test-id-token",
                "tokenType" to "Bearer",
            ));
        val handler = SaveCredentialsRequestHandler();
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        val exception = Assert.assertThrows(IllegalArgumentException::class.java) {
            handler.handle(
                mockCredentialsManager,
                mock(),
                request,
                mockResult
            );
        }

        assertThat(
            exception.message,
            equalTo("Required property 'credentials.expiresAt' is not provided.")
        );
    }

    @Test
    fun `should call saveCredentials with the correct parameters`() {
        val handler = SaveCredentialsRequestHandler();
        var credentialsMap = hashMapOf(
            "accessToken" to "test-access-token",
            "idToken" to "test-access-token",
            "tokenType" to "Bearer",
            "expiresAt" to "2022-01-01T00:00:00.000Z",
            "scopes" to arrayListOf("a", "b")
        );
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        var date = format.parse(credentialsMap.get("expiresAt") as String);
        var scope: String? = null;
        val scopes = credentialsMap.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ");
        }


        var credentials = Credentials(
            credentialsMap.get("idToken") as String,
            credentialsMap.get("accessToken") as String,
            credentialsMap.get("tokenType") as String,
            credentialsMap.get("refreshToken") as String?,
            date,
            scope,
        )
        val options = hashMapOf(
            "credentials" to credentialsMap,
        );
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        );


        val captor = argumentCaptor<Credentials>()
        verify(mockCredentialsManager).saveCredentials(captor.capture());

        assertThat((captor.firstValue as Credentials).accessToken, equalTo(credentials.accessToken))

    }

    @Test
    fun `should call saveCredentials with the correct parameters without scopes`() {
        val handler = SaveCredentialsRequestHandler();
        var credentialsMap = hashMapOf(
            "accessToken" to "test-access-token",
            "idToken" to "test-access-token",
            "tokenType" to "Bearer",
            "expiresAt" to "2022-01-01T00:00:00.000Z"
        );
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        var date = format.parse(credentialsMap.get("expiresAt") as String);
        var scope: String? = null;
        val scopes = credentialsMap.getOrDefault("scopes", arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            scope = scopes.joinToString(separator = " ");
        }


        var credentials = Credentials(
            credentialsMap.get("idToken") as String,
            credentialsMap.get("accessToken") as String,
            credentialsMap.get("tokenType") as String,
            credentialsMap.get("refreshToken"),
            date,
            scope,
        )
        val options = hashMapOf(
            "credentials" to credentialsMap,
        );
        val mockResult = mock<Result>();
        val mockAccount = mock<Auth0>();
        var mockCredentialsManager = mock<SecureCredentialsManager>();
        val request = MethodCallRequest(account = mockAccount, options);

        handler.handle(
            mockCredentialsManager,
            mock(),
            request,
            mockResult
        );


        val captor = argumentCaptor<Credentials>()
        verify(mockCredentialsManager).saveCredentials(captor.capture());

        assertThat((captor.firstValue as Credentials).accessToken, equalTo(credentials.accessToken))

    }
}
