package com.auth0.auth0_flutter.request_handlers

import com.auth0.android.Auth0
import com.auth0.android.util.Auth0UserAgent
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodCall

class MethodCallRequest {
    var account: Auth0;
    var data: HashMap<*, *>;

    constructor(account: Auth0, data: HashMap<*, *>) {
        this.data = data;
        this.account = account;

    }

    companion object {
        fun fromCall(call: MethodCall): MethodCallRequest {
            val args = call.arguments as HashMap<*, *>;

            assertHasProperties(
                listOf(
                    "domain",
                    "clientId",
                    "telemetry",
                    "telemetry.name",
                    "telemetry.version"
                ), args
            );

            val account = Auth0(
                args["clientId"] as String,
                args["domain"] as String
            )

            val telemetry = args["telemetry"] as Map<String, String>;

            account.auth0UserAgent = Auth0UserAgent(
                name = telemetry["name"] as String,
                version = telemetry["version"] as String,
            )

            return MethodCallRequest(account, args);
        }
    }
}
