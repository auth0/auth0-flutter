package com.auth0.auth0_flutter_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val passkeyAuthenticator = PasskeyAuthenticator()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        passkeyAuthenticator.activity = this
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PasskeyAuthenticator.CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            passkeyAuthenticator.handle(call, result)
        }
    }

    override fun onDestroy() {
        // Clear the Activity reference so it isn't retained past its lifecycle,
        // mirroring the SDK's onDetachedFromActivity handling.
        passkeyAuthenticator.activity = null
        super.onDestroy()
    }
}
