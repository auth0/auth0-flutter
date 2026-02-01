package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import com.auth0.auth0_flutter.request_handlers.credentials_manager.ClearCredentialsRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.GetCredentialsUserInfoRequestHandler
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

        handler.onMethodCall(call1, mockResult)
        verify(clearCredentialsHandler, times(1)).handle(any(), eq(context), any(), any())

        handler.onMethodCall(call2, mockResult)
        verify(clearCredentialsHandler, times(2)).handle(any(), eq(context), any(), any())

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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

        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test2.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        verify(clearCredentialsHandler, times(2)).handle(any(), eq(context), any(), any())

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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

        val arguments2 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "client-2",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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
                "android" to mapOf("sharedPreferencesName" to "prefs_2")
            )
        )
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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

        val arguments2 = hashMapOf<String, Any?>(
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
        val call2 = MethodCall("credentialsManager#clearCredentials", arguments2)
        handler.onMethodCall(call2, mockResult)

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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

        val arguments1 = hashMapOf<String, Any?>(
            "_account" to mapOf(
                "domain" to "test.auth0.com",
                "clientId" to "test-client",
            ),
            "_userAgent" to mapOf(
                "name" to "auth0-flutter",
                "version" to "1.0.0"
            )
        )
        val call1 = MethodCall("credentialsManager#clearCredentials", arguments1)
        handler.onMethodCall(call1, mockResult)

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

        val managerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        verify(clearCredentialsHandler, times(2)).handle(managerCaptor.capture(), any(), any(), any())

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

        val call1 = MethodCall("credentialsManager#clearCredentials", arguments)
        handler.onMethodCall(call1, mockResult)

        val call2 = MethodCall("credentialsManager#hasValidCredentials", arguments)
        handler.onMethodCall(call2, mockResult)

        val clearManagerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()
        val hasValidManagerCaptor = argumentCaptor<com.auth0.android.authentication.storage.SecureCredentialsManager>()

        verify(clearCredentialsHandler).handle(clearManagerCaptor.capture(), any(), any(), any())
        verify(hasValidCredentialsHandler).handle(hasValidManagerCaptor.capture(), any(), any(), any())

        MatcherAssert.assertThat(
            "Same manager should be reused across different method calls with identical configuration",
            clearManagerCaptor.firstValue,
            CoreMatchers.sameInstance(hasValidManagerCaptor.firstValue)
        )
    }

    @Test
    fun `handler invokes GetCredentialsUserInfoRequestHandler for credentialsManager#user`() {
        val getUserInfoHandler = mock<GetCredentialsUserInfoRequestHandler>()
        `when`(getUserInfoHandler.handles).thenReturn("credentialsManager#user")

        runCallHandler(
            "credentialsManager#user",
            requestHandlers = listOf(getUserInfoHandler)
        ) { result ->
            verify(getUserInfoHandler).handle(any(), any(), any(), any())
        }
    }

    @Test
    fun `handler returns UserProfile result from GetCredentialsUserInfoRequestHandler`() {
        val getUserInfoHandler = mock<GetCredentialsUserInfoRequestHandler>()
        `when`(getUserInfoHandler.handles).thenReturn("credentialsManager#user")

        val userProfileMap = mapOf(
            "sub" to "auth0|123456",
            "name" to "John Doe",
            "email" to "john.doe@example.com"
        )

        doAnswer { invocation ->
            val result = invocation.getArgument<Result>(3)
            result.success(userProfileMap)
        }.`when`(getUserInfoHandler).handle(any(), any(), any(), any())

        val mockResult = mock<Result>()
        val handler = CredentialsManagerMethodCallHandler(listOf(getUserInfoHandler))
        handler.activity = mock()
        handler.context = mock()

        handler.onMethodCall(MethodCall("credentialsManager#user", defaultArguments), mockResult)

        verify(mockResult).success(userProfileMap)
    }
}

