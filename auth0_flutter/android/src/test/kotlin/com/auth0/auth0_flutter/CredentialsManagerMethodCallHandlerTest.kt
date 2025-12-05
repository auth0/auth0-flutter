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

    // ========================================================================================
    // CACHING TESTS - Test manager reuse when configuration hasn't changed
    // ========================================================================================

    @Test
    fun `handler should reuse cached manager when configuration is identical`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        val arguments = defaultArguments.toMutableMap()
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments)
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments)

        // First call - should create manager
        handler.onMethodCall(call1, mockResult)
        verify(clearCredentialsHandler, times(1)).handle(any(), eq(context), any(), any())

        // Second call with same configuration - should reuse cached manager
        handler.onMethodCall(call2, mockResult)
        verify(clearCredentialsHandler, times(2)).handle(any(), eq(context), any(), any())

        // The same manager instance should be passed both times
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify both calls received the same manager instance
        MatcherAssert.assertThat(
            "Manager should be reused when configuration is identical",
            managerCaptor.firstValue,
            CoreMatchers.sameInstance(managerCaptor.secondValue)
        )
    }

    @Test
    fun `handler should create new manager when domain changes`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // First call with original domain
        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test1.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

        // Second call with different domain
        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test2.auth0.com",  // Different domain
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Verify both calls were handled
        verify(clearCredentialsHandler, times(2)).handle(any(), eq(context), any(), any())

        // Capture the managers to verify they are different instances
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify different manager instances were created
        MatcherAssert.assertThat(
            "New manager should be created when domain changes",
            managerCaptor.firstValue,
            CoreMatchers.not(CoreMatchers.sameInstance(managerCaptor.secondValue))
        )
    }

    @Test
    fun `handler should create new manager when clientId changes`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // First call with original clientId
        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "client-1",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

        // Second call with different clientId
        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "client-2",  // Different clientId
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Capture the managers to verify they are different instances
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify different manager instances were created
        MatcherAssert.assertThat(
            "New manager should be created when clientId changes",
            managerCaptor.firstValue,
            CoreMatchers.not(CoreMatchers.sameInstance(managerCaptor.secondValue))
        )
    }

    @Test
    fun `handler should create new manager when sharedPreferencesName changes`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // First call with original shared preferences name
        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "credentialsManagerConfiguration" to mapOf(
                "android" to mapOf("sharedPreferencesName" to "prefs_1")
            )
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

        // Second call with different shared preferences name
        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "credentialsManagerConfiguration" to mapOf(
                "android" to mapOf("sharedPreferencesName" to "prefs_2")  // Different name
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Capture the managers to verify they are different instances
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify different manager instances were created
        MatcherAssert.assertThat(
            "New manager should be created when sharedPreferencesName changes",
            managerCaptor.firstValue,
            CoreMatchers.not(CoreMatchers.sameInstance(managerCaptor.secondValue))
        )
    }

    @Test
    fun `handler should create new manager when useDPoP flag changes`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // First call without DPoP
        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "useDPoP" to false
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

        // Second call with DPoP enabled
        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "useDPoP" to true  // DPoP flag changed
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Capture the managers to verify they are different instances
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify different manager instances were created
        MatcherAssert.assertThat(
            "New manager should be created when useDPoP flag changes",
            managerCaptor.firstValue,
            CoreMatchers.not(CoreMatchers.sameInstance(managerCaptor.secondValue))
        )
    }

    @Test
    fun `handler should create new manager when localAuthentication changes`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: androidx.fragment.app.FragmentActivity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // First call without localAuthentication
        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
            // No localAuthentication
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

        // Second call with localAuthentication enabled
        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "localAuthentication" to mapOf(
                "title" to "Authenticate",
                "description" to "Biometric auth required",
                "cancelTitle" to "Cancel",
                "authenticationLevel" to 0
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Capture the managers to verify they are different instances
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify different manager instances were created
        MatcherAssert.assertThat(
            "New manager should be created when localAuthentication changes",
            managerCaptor.firstValue,
            CoreMatchers.not(CoreMatchers.sameInstance(managerCaptor.secondValue))
        )
    }

    @Test
    fun `handler should reuse manager across different method calls with same configuration`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        val hasValidCredentialsHandler = mock<HasValidCredentialsRequestHandler>()
        
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")
        `when`(hasValidCredentialsHandler.method).thenReturn("credentialsManager#hasValidCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler, hasValidCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        val arguments = defaultArguments.toMutableMap()

        // Call clearCredentials
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call1, mockResult)

        // Call hasValidCredentials with same configuration
        val call2 = MethodCall("credentialsManager#hasValidCredentials", arguments)
        handler.onMethodCall(call2, mockResult)

        // Capture managers from both handlers
        val clearManagerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        val hasValidManagerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        
        verify(clearCredentialsHandler).handle(clearManagerCaptor.capture(), any(), any(), any())
        verify(hasValidCredentialsHandler).handle(hasValidManagerCaptor.capture(), any(), any(), any())
        
        // Verify the same manager instance was reused across different method calls
        MatcherAssert.assertThat(
            "Same manager should be reused across different method calls with identical configuration",
            clearManagerCaptor.firstValue,
            CoreMatchers.sameInstance(hasValidManagerCaptor.firstValue)
        )
    }

    // ========================================================================================
    // DPOP TESTS - Test manager behavior with DPoP enabled/disabled
    // ========================================================================================

    @Test
    fun `handler should create manager with DPoP enabled when useDPoP is true`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // Call with DPoP enabled
        val arguments = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "useDPoP" to true  // DPoP enabled
        )
        val call = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call, mockResult)

        // Verify handler was called (manager was created successfully with DPoP)
        verify(clearCredentialsHandler).handle(any(), eq(context), any(), any())
    }

    @Test
    fun `handler should reuse manager when DPoP flag remains true`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        val arguments = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "useDPoP" to true
        )

        // First call with DPoP enabled
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call1, mockResult)

        // Second call with DPoP still enabled (same configuration)
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call2, mockResult)

        // Capture managers
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify same manager instance was reused
        MatcherAssert.assertThat(
            "Same manager should be reused when DPoP flag remains true",
            managerCaptor.firstValue,
            CoreMatchers.sameInstance(managerCaptor.secondValue)
        )
    }

    @Test
    fun `handler should treat missing useDPoP as false for caching`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: Activity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        val baseArguments = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )

        // First call without useDPoP (defaults to false)
        val call1 = MethodCall("credentialsManager#clearCredentials", baseArguments)
        handler.onMethodCall(call1, mockResult)

        // Second call with explicit useDPoP=false
        val arguments2 = baseArguments.toMutableMap()
        arguments2["useDPoP"] = false
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        // Capture managers
        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())
        
        // Verify same manager instance was reused (missing treated as false)
        MatcherAssert.assertThat(
            "Same manager should be reused when useDPoP is missing (defaults to false) and then explicitly false",
            managerCaptor.firstValue,
            CoreMatchers.sameInstance(managerCaptor.secondValue)
        )
    }

    @Test
    fun `handler should work with DPoP and localAuthentication combined`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")

        val handler = CredentialsManagerMethodCallHandler(listOf(clearCredentialsHandler))
        val mockResult = mock<Result>()
        val activity: androidx.fragment.app.FragmentActivity = mock()
        val context: Context = mock()
        val mockPrefs: SharedPreferences = mock()

        `when`(context.getSharedPreferences(any(), any())).thenReturn(mockPrefs)

        handler.activity = activity
        handler.context = context

        // Call with both DPoP and localAuthentication enabled
        val arguments = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            ),
            "useDPoP" to true,
            "localAuthentication" to mapOf(
                "title" to "Authenticate",
                "description" to "Biometric auth required",
                "cancelTitle" to "Cancel",
                "authenticationLevel" to 0
            )
        )
        val call = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call, mockResult)

        // Verify handler was called (manager created with both DPoP and biometric auth)
        verify(clearCredentialsHandler).handle(any(), eq(context), any(), any())
    }
}

