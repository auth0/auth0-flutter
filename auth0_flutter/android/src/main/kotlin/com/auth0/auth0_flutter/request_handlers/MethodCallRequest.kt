package com.auth0.auth0_flutter.request_handlers

import com.auth0.android.Auth0
import com.auth0.android.util.Auth0UserAgent
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodCall

class MethodCallRequest {
    var account: Auth0
    var data: HashMap<*, *>

    constructor(account: Auth0, data: HashMap<*, *>) {
        this.data = data
        this.account = account

    }

    companion object {
        fun fromCall(call: MethodCall): MethodCallRequest {
            val args = call.arguments as HashMap<*, *>

            assertHasProperties(
                listOf(
                    "_account",
                    "_account.domain",
                    "_account.clientId",
                    "_userAgent",
                    "_userAgent.name",
                    "_userAgent.version"
                ), args
            )

            val accountMap = args["_account"] as Map<String, String>
            val account = Auth0(
                accountMap["clientId"] as String,
                accountMap["domain"] as String
            )

            val userAgentMap = args["_userAgent"] as Map<String, String>
            account.auth0UserAgent = Auth0UserAgent(
                name = userAgentMap["name"] as String,
                version = userAgentMap["version"] as String,
            )

            return MethodCallRequest(account, args)
        }
    }
}
