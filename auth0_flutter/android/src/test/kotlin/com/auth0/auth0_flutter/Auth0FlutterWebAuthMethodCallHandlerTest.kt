package com.auth0.auth0_flutter

//import kotlin.test.assertEquals
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.*
import org.hamcrest.MatcherAssert.assertThat
import org.hamcrest.Matchers.*
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterWebAuthMethodCallHandlerTest {

    @Test
    fun `handler should log in using the Auth0 SDK`() {
        val handler = Auth0FlutterWebAuthMethodCallHandler()
        val mockResult = mock(Result::class.java)

        handler.context = mock(Context::class.java)
        handler.requestHandlers[WEBAUTH_LOGIN_METHOD]

        val args = hashMapOf(
            "domain" to "test.auth0.com",
            "clientId" to "test-client"
        )

        handler.onMethodCall(MethodCall("webAuth#login", args), mockResult)
    }
}
