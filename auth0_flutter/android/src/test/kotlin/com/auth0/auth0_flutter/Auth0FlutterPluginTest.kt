package com.auth0.auth0_flutter

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.*
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.mock
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class Auth0FlutterPluginTest {
    @Test
    fun `should set MethodCallHandler on onAttachedToEngine`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin()

            val mockBindings = mock<FlutterPluginBinding>()
            val mockContext = mock<Context>()
            val mockMessenger = mock<io.flutter.plugin.common.BinaryMessenger>()
            `when`(mockBindings.applicationContext).thenReturn(mockContext)
            `when`(mockBindings.binaryMessenger).thenReturn(mockMessenger)
            plugin.onAttachedToEngine(mockBindings)

            val constructed: List<MethodChannel> = m.constructed()

            fun <TMethodCalHandler : MethodChannel.MethodCallHandler> assertMethodcallHandler(i: Int) {
                verify(constructed[i]).setMethodCallHandler(
                    any<TMethodCalHandler>()
                )
            }

            assertMethodcallHandler<Auth0FlutterWebAuthMethodCallHandler>(0)
            assertMethodcallHandler<Auth0FlutterAuthMethodCallHandler>(1)
            assertMethodcallHandler<CredentialsManagerMethodCallHandler>(2)
            assertMethodcallHandler<Auth0FlutterDPoPMethodCallHandler>(3)

            assert(constructed.size == 4)
        }
    }

    @Test
    fun `should set MethodCallHandler to null on onDetachedFromEngine`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin()

            val mockBindings = mock<FlutterPluginBinding>()
            val mockContext = mock<Context>()
            val mockMessenger = mock<io.flutter.plugin.common.BinaryMessenger>()
            `when`(mockBindings.applicationContext).thenReturn(mockContext)
            `when`(mockBindings.binaryMessenger).thenReturn(mockMessenger)
            plugin.onAttachedToEngine(mockBindings)

            val constructed: List<MethodChannel> = m.constructed()

            plugin.onDetachedFromEngine(mock())

            fun assertMethodcallHandler(i: Int) {
                verify(constructed[i]).setMethodCallHandler(
                    isNull()
                )
            }

            assertMethodcallHandler(0)
            assertMethodcallHandler(1)
            assertMethodcallHandler(2)
            assertMethodcallHandler(3)

            assert(constructed.size == 4)
        }
    }

    @Test
    fun `should set Activity on onAttachedToActivity and ApplicationContext on onAttachedToEngine`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin()

            val mockBindings = mock<FlutterPluginBinding>()
            val mockContext = mock<Context>()
            val mockMessenger = mock<io.flutter.plugin.common.BinaryMessenger>()
            `when`(mockBindings.applicationContext).thenReturn(mockContext)
            `when`(mockBindings.binaryMessenger).thenReturn(mockMessenger)
            plugin.onAttachedToEngine(mockBindings)

            val constructed: List<MethodChannel> = m.constructed()

            val mockActivityBindings = mock<ActivityPluginBinding>()
            val mockActivity = mock<Activity>()
            `when`(mockActivityBindings.activity).thenReturn(mockActivity)

            plugin.onAttachedToActivity(mockActivityBindings)

            fun <TMethodCallHandler : MethodChannel.MethodCallHandler> getHandler(i: Int): TMethodCallHandler {
                val captor = argumentCaptor<MethodChannel.MethodCallHandler>()

                verify(constructed[i]).setMethodCallHandler(captor.capture())

                @Suppress("UNCHECKED_CAST")
                return captor.firstValue as TMethodCallHandler
            }

            assert(getHandler<Auth0FlutterWebAuthMethodCallHandler>(0).activity == mockActivity)
            assert(getHandler<CredentialsManagerMethodCallHandler>(1).activity == mockActivity)
            assert(getHandler<CredentialsManagerMethodCallHandler>(1).context == mockContext)

            assert(constructed.size == 4)
        }
    }
}
