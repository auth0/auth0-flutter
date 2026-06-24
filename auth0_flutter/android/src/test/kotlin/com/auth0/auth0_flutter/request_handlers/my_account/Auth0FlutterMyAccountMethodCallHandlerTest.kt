package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.Auth0
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.auth0_flutter.Auth0FlutterMyAccountMethodCallHandler
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.`when`
import org.mockito.kotlin.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterMyAccountMethodCallHandlerTest {
    private val defaultArguments = hashMapOf<String, Any?>(
        "_account" to mapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client",
        ),
        "_userAgent" to mapOf(
            "name" to "auth0-flutter",
            "version" to "1.0.0"
        ),
        "accessToken" to "test-token"
    )

    @Test
    fun `handler should result in notImplemented if no matching handler`() {
        val handler = Auth0FlutterMyAccountMethodCallHandler(emptyList())
        val mockResult = mock<Result>()

        handler.onMethodCall(MethodCall("myAccount#unknown", defaultArguments), mockResult)

        verify(mockResult).notImplemented()
    }

    @Test
    fun `handler should call the correct handler when matched`() {
        val mockRequestHandler = mock<MyAccountRequestHandler>()
        `when`(mockRequestHandler.method).thenReturn("myAccount#getFactors")

        val handler = Auth0FlutterMyAccountMethodCallHandler(listOf(mockRequestHandler))
        val mockResult = mock<Result>()

        handler.onMethodCall(MethodCall("myAccount#getFactors", defaultArguments), mockResult)

        verify(mockRequestHandler).handle(any(), any(), eq(mockResult))
    }

    @Test
    fun `handler should not call non-matching handlers`() {
        val getFactorsHandler = mock<MyAccountRequestHandler>()
        val enrollPhoneHandler = mock<MyAccountRequestHandler>()

        `when`(getFactorsHandler.method).thenReturn("myAccount#getFactors")
        `when`(enrollPhoneHandler.method).thenReturn("myAccount#enrollPhone")

        val handler = Auth0FlutterMyAccountMethodCallHandler(listOf(getFactorsHandler, enrollPhoneHandler))
        val mockResult = mock<Result>()

        handler.onMethodCall(MethodCall("myAccount#getFactors", defaultArguments), mockResult)

        verify(getFactorsHandler).handle(any(), any(), eq(mockResult))
        verify(enrollPhoneHandler, times(0)).handle(any(), any(), any())
    }
}
