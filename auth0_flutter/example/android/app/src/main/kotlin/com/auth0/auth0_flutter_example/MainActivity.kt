package com.auth0.auth0_flutter_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val passkeyAuthenticator = PasskeyAuthenticator()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PasskeyAuthenticator.CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            passkeyAuthenticator.handle(this, call, result)
        }
    }
}
