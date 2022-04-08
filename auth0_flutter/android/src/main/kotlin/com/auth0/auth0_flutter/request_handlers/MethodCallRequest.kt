package com.auth0.auth0_flutter.request_handlers

import com.auth0.android.Auth0
import io.flutter.plugin.common.MethodCall

class MethodCallRequest {
    var account: Auth0;
    var data: HashMap<*, *>;

    constructor(domain: String, clientId: String, data: HashMap<*, *>) {
        this.data = data;
        this.account = Auth0(
            clientId,
            domain
        )
    }

    companion object {
        fun fromCall(call: MethodCall): MethodCallRequest {
            val args = call.arguments as HashMap<*, *>;

            return MethodCallRequest(args["domain"] as String, args["clientId"] as String, args);
        }
    }
}
