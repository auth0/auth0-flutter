package com.auth0.auth0_flutter

import android.app.Activity
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
        activity: Activity? = null,
        onResult: (Result) -> Unit,
    ) {
        val handler = CredentialsManagerMethodCallHandler(requestHandlers)
        val mockResult = mock<Result>()

        handler.activity = if (activity === null)  mock() else activity;

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
    fun `handler should not call credentialsManager requireAuthentication`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");

        val activity: Activity = mock();
        val mockPrefs: SharedPreferences = mock()

        `when`(activity.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs);

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()

        handler.activity = activity;
        handler.credentialsManager = mock();

        handler.onMethodCall(MethodCall(clearCredentialsHandler.method, defaultArguments), mockResult)

        verify(handler.credentialsManager, never())?.requireAuthentication(any(), any(), any(), any())
    }

    @Test
    fun `handler should call credentialsManager requireAuthentication`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");

        val activity: Activity = mock();
        val mockPrefs: SharedPreferences = mock()

        `when`(activity.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs);

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()

        handler.activity = activity;
        handler.credentialsManager = mock();

        handler.onMethodCall(MethodCall(clearCredentialsHandler.method, defaultArguments + hashMapOf("localAuthentication" to hashMapOf("title" to "test", "description" to "test description"))), mockResult)

        verify(handler.credentialsManager)?.requireAuthentication(eq(activity), eq(111), eq("test"), eq("test description"))
    }

    @Test
    fun `handler should call credentialsManager requireAuthentication with default values`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");

        val activity: Activity = mock();
        val mockPrefs: SharedPreferences = mock()

        `when`(activity.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs);

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()

        handler.activity = activity;
        handler.credentialsManager = mock();

        handler.onMethodCall(MethodCall(clearCredentialsHandler.method, defaultArguments + hashMapOf("localAuthentication" to hashMapOf<String, String>())), mockResult)

        verify(handler.credentialsManager)?.requireAuthentication(eq(activity), eq(111), isNull(), isNull())
    }

    @Test
    fun `handler should only run the correct handler`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>();
        val hasValidCredentialsHandler = mock<HasValidCredentialsRequestHandler>();

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials");
        `when`(hasValidCredentialsHandler.method).thenReturn("credentialsManager#hasValidCredentials");

        val activity: Activity = mock();
        val mockPrefs: SharedPreferences = mock();

        `when`(activity.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs);

        runCallHandler(clearCredentialsHandler.method, activity = activity, requestHandlers = listOf(clearCredentialsHandler, hasValidCredentialsHandler)) { _ ->
            verify(clearCredentialsHandler).handle(any(), eq(activity), any(), any())
            verify(hasValidCredentialsHandler, times(0)).handle(any(), eq(activity), any(), any())
        }
    }
}
