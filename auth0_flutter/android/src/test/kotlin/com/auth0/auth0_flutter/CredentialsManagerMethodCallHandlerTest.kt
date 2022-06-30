package com.auth0.auth0_flutter

import android.content.Context
import android.content.SharedPreferences
import com.auth0.auth0_flutter.request_handlers.api.ApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.LoginApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.api.SignupApiRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.ClearCredentialsRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.HasValidCredentialsRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class CredentialsManagerMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "_account" to mapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client",
        ),
        "_userAgent" to mapOf(
            "name" to "auth0-flutter",
            "version" to "1.0.0"
        )
    )

    private fun runCallHandler(
        method: String,
        arguments: HashMap<String, Any?> = defaultArguments,
        requestHandlers: List<CredentialsManagerRequestHandler>,
        context: Context? = null,
        onResult: (Result) -> Unit,
    ) {
        val handler = CredentialsManagerMethodCallHandler(requestHandlers)
        val mockResult = mock<Result>()

        handler.context = if (context === null)  mock() else context;

        handler.onMethodCall(MethodCall(method, arguments), mockResult)
        onResult(mockResult)
    }

    @Test
    fun `handler should result in 'notImplemented' if no handlers`() {
        runCallHandler("credentialsManager#clearCredentials", requestHandlers = listOf()) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should result in 'notImplemented' if no matching handler`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");

        runCallHandler("credentialsManager#saveCredentials", requestHandlers = listOf(clearCredentialsHandler)) { result ->
            verify(result).notImplemented()
        }
    }

    @Test
    fun `handler should only run the correct handler`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();
        val hasValidCredentialsHandler = mock<HasValidCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");
        `when`(hasValidCredentialsHandler.method).thenReturn("credentialsManager#hasValidCredentials");

        val context: Context = mock();
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs);

        runCallHandler(clearCredentialsHandler.method, context = context, requestHandlers = listOf(clearCredentialsHandler, hasValidCredentialsHandler)) { _ ->
            verify(clearCredentialsHandler).handle(any(), eq(context), any(), any())
            verify(hasValidCredentialsHandler, times(0)).handle(any(), eq(context), any(), any())
        }
    }
}
