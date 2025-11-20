package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import androidx.fragment.app.FragmentActivity
import com.auth0.android.Auth0
import com.auth0.android.authentication.storage.AuthenticationLevel
import com.auth0.android.authentication.storage.LocalAuthenticationOptions
import com.auth0.android.authentication.storage.SecureCredentialsManager
import com.auth0.auth0_flutter.request_handlers.credentials_manager.ClearCredentialsRequestHandler
import com.auth0.auth0_flutter.request_handlers.credentials_manager.CredentialsManagerRequestHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.hamcrest.CoreMatchers.`is`
import org.hamcrest.MatcherAssert.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mockConstruction
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
        activity: Activity,
        onResult: (Result) -> Unit,
    ) {
        val handler = CredentialsManagerMethodCallHandler(requestHandlers)
        val mockResult = mock<Result>()

        handler.activity = activity
        handler.context = mock()
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
    fun `handler should instantiate SecureCredentialsManager without biometrics`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")
        val activity: Activity = mock()

        mockConstruction(SecureCredentialsManager::class.java).use {
            runCallHandler("credentialsManager#clearCredentials", activity = activity, requestHandlers = listOf(clearCredentialsHandler)) {}

            // Verify the simple constructor was called, without FragmentActivity or LocalAuthenticationOptions
            val constructorInvocations = it.constructorInvocations()
            assertThat(constructorInvocations.size, `is`(1))
            val constructorArgs = constructorInvocations[0].arguments()
            assertThat(constructorArgs[0], isA(Context::class.java))
            assertThat(constructorArgs[1], isA(Auth0::class.java))
            assertThat(constructorArgs[2], isA(com.auth0.android.authentication.storage.Storage::class.java))
            assertThat(constructorArgs.size, `is`(3)) // Should only have 3 arguments
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
    fun `handler should instantiate SecureCredentialsManager with biometrics`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")
        val activity: FragmentActivity = mock() // Use FragmentActivity

        val arguments = defaultArguments + hashMapOf(
            "localAuthentication" to hashMapOf(
                "title" to "Test Title",
                "description" to "Test Description"
            )
        )

        mockConstruction(SecureCredentialsManager::class.java).use {
            runCallHandler("credentialsManager#clearCredentials", arguments = arguments, activity = activity, requestHandlers = listOf(clearCredentialsHandler)) {}

            // Verify the complex constructor for biometrics was called
            val constructorInvocations = it.constructorInvocations()
            assertThat(constructorInvocations.size, `is`(1))
            val constructorArgs = constructorInvocations[0].arguments()
            assertThat(constructorArgs[0], isA(Context::class.java))
            assertThat(constructorArgs[1], isA(Auth0::class.java))
            assertThat(constructorArgs[2], isA(com.auth0.android.authentication.storage.Storage::class.java))
            assertThat(constructorArgs[3], isA(FragmentActivity::class.java))
            assertThat(constructorArgs[4], isA(LocalAuthenticationOptions::class.java))

            // Verify the options passed to the constructor
            val localAuthOptions = constructorArgs[4] as LocalAuthenticationOptions
            assertThat(localAuthOptions.title, `is`("Test Title"))
            assertThat(localAuthOptions.description, `is`("Test Description"))
            assertThat(localAuthOptions.authenticationLevel, `is`(AuthenticationLevel.STRONG))
        }
    }

    @Test
    fun `handler should throw error if biometrics are requested but activity is not FragmentActivity`() {
        val clearCredentialsHandler = mock<ClearCredentialsRequestHandler>()
        `when`(clearCredentialsHandler.method).thenReturn("credentialsManager#clearCredentials")
        val activity: Activity = mock() // Use standard Activity

        val arguments = defaultArguments + hashMapOf(
            "localAuthentication" to hashMapOf("title" to "Test Title")
        )

        runCallHandler("credentialsManager#clearCredentials", arguments = arguments, activity = activity, requestHandlers = listOf(clearCredentialsHandler)) { result ->
            val codeCaptor = argumentCaptor<String>()
            val messageCaptor = argumentCaptor<String>()
            verify(result).error(codeCaptor.capture(), messageCaptor.capture(), isNull())
            assertThat(codeCaptor.firstValue, `is`("credentialsManager#biometric-error"))
            assertThat(messageCaptor.firstValue, `is`("The Activity is not a FragmentActivity, which is required for biometric authentication."))
        }
    }
}
