package com.auth0.auth0_flutter

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import org.hamcrest.CoreMatchers
import org.hamcrest.MatcherAssert
import org.hamcrest.MatcherAssert.assertThat
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

            val plugin = Auth0FlutterPlugin();

            plugin.onAttachedToEngine(mock());

            val constructed: List<MethodChannel> = m.constructed()

            fun <TMethodCalHandler : MethodChannel.MethodCallHandler> assertMethodcallHandler(i: Int) {
                verify(constructed[i]).setMethodCallHandler(
                    any<TMethodCalHandler>()
                )
            }

            assertMethodcallHandler<Auth0FlutterAuthMethodCallHandler>(0);
            assertMethodcallHandler<Auth0FlutterAuthMethodCallHandler>(1);
            assertMethodcallHandler<CredentialsManagerMethodCallHandler>(2);

            assert(constructed.size == 3);
        }
    }

    @Test
    fun `should set MethodCallHandler to null on onDetachedFromEngine`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin();

            plugin.onAttachedToEngine(mock());

            val constructed: List<MethodChannel> = m.constructed()

            plugin.onDetachedFromEngine(mock());

            fun <TMethodCalHandler : MethodChannel.MethodCallHandler> assertMethodcallHandler(i: Int) {
                verify(constructed[i]).setMethodCallHandler(
                    isNull()
                )
            }

            assertMethodcallHandler<Auth0FlutterAuthMethodCallHandler>(0);
            assertMethodcallHandler<Auth0FlutterAuthMethodCallHandler>(1);
            assertMethodcallHandler<CredentialsManagerMethodCallHandler>(2);

            assert(constructed.size == 3);
        }
    }

    @Test
    fun `should set Activity on onAttachedToActivity`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin();

            plugin.onAttachedToEngine(mock());

            val constructed: List<MethodChannel> = m.constructed()

            val mockBindings = mock<ActivityPluginBinding>();
            val mockActivity = mock<Activity>();
            `when`(mockBindings.activity).thenReturn(mockActivity);

            plugin.onAttachedToActivity(mockBindings);

            fun <TMethodCalHandler : MethodChannel.MethodCallHandler> getHandler(i: Int): TMethodCalHandler {
                val captor = argumentCaptor<MethodChannel.MethodCallHandler>();

                verify(constructed[i]).setMethodCallHandler(captor.capture());

                return captor.firstValue as TMethodCalHandler;
            }

            assert(getHandler<Auth0FlutterWebAuthMethodCallHandler>(0).activity == mockActivity);
            assert(getHandler<CredentialsManagerMethodCallHandler>(2).activity == mockActivity);

            assert(constructed.size == 3);
        }
    }

    @Test
    fun `should call binding addActivityResultListener for CredentialsManager on onAttachedToActivity`() {
        mockConstruction(MethodChannel::class.java).use { m ->
            val plugin = Auth0FlutterPlugin();

            plugin.onAttachedToEngine(mock());

            val mockBindings = mock<ActivityPluginBinding>();
            val mockActivity = mock<Activity>();

            `when`(mockBindings.activity).thenReturn(mockActivity);

            plugin.onAttachedToActivity(mockBindings);

            verify(mockBindings).addActivityResultListener(
                any<CredentialsManagerMethodCallHandler>()
            )
        }
    }
}
