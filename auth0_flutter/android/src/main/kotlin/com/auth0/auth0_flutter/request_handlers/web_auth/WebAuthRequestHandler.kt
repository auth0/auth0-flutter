package com.auth0.auth0_flutter.request_handlers.web_auth

import android.content.Context
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import io.flutter.plugin.common.MethodChannel

interface WebAuthRequestHandler {
    fun handle(context: Context, request: MethodCallRequest, result: MethodChannel.Result)
}

