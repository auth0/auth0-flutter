package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

interface MyAccountRequestHandler {
    val method: String
    fun handle(client: MyAccountAPIClient, request: MethodCallRequest, result: MethodChannel.Result)
}
