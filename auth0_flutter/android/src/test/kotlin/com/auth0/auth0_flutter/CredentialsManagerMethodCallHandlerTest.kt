package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import com.auth0.auth0_flutter.request_handlers.credentials_manager.ClearCredentialsRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.HasValidCredentialsRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
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
        context: Context? = null,
        onResult: (Result) -> Unit,
    ) {
        val handler = CredentialsManagerMethodCallHandler(requestHandlers)
        val mockResult = mock<Result>()

        handler.activity = if (activity === null)  mock() else activity
        handler.context = if (context === null)  mock() else context

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
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        runCallHandler("credentialsManager#saveCredentials", requestHandlers = listOf(clearCredentialsHandler)) { result ->
            verify(result).notImplemented()
        }
    }

    // Test disabled: credentialsManager is no longer a public property with Auth0 Android SDK 3.11.0
    // It's now created internally per request with local authentication options support

    @Test
    fun `handler should extract sharedPreferenceName correctly`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs)

        val arguments = defaultArguments + hashMapOf(
            "credentialsManagerConfiguration" to mapOf(
                "android" to mapOf("sharedPreferencesName" to "test_prefs")
            )
        )

        runCallHandler(clearCredentialsHandler.method, arguments as HashMap, listOf(clearCredentialsHandler), activity, context) {
            verify(context).getSharedPreferences(eq("test_prefs"), any())
        }
    }

    // Test disabled: credentialsManager is no longer a public property with Auth0 Android SDK 3.11.0
    // Local authentication is now handled via LocalAuthenticationOptions in the SDK

    // Test disabled: credentialsManager is no longer a public property with Auth0 Android SDK 3.11.0
    // Local authentication is now handled via LocalAuthenticationOptions in the SDK

    @Test
    fun `handler should only run the correct handler`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        val hasValidCredentialsHandler = mock<HasValidCredentialsRequestHandler>()

        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")
        `when`(hasValidCredentialsHandler.method).thenReturn("credentialsManager#hasValidCredentials")

        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any()))
            .thenReturn(mockPrefs)

        runCallHandler(clearCredentialsHandler.method, activity = activity, context = context, requestHandlers = listOf(clearCredentialsHandler, hasValidCredentialsHandler)) {
            verify(clearCredentialsHandler).handle(any(), eq(context), any(), any())
            verify(hasValidCredentialsHandler, times(0)).handle(any(), eq(context), any(), any())
        }
    }

    // Tests disabled: onActivityResult and credentialsManager no longer exist
    // Auth0 Android SDK 3.11.0 handles biometric authentication internally without activity results
}
