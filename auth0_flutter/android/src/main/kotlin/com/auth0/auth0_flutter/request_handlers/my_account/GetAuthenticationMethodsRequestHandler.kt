package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.AuthenticationMethodType
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.AuthenticationMethod
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountMethodMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_GET_AUTH_METHODS_METHOD =
    "myAccount#getAuthenticationMethods"

class GetAuthenticationMethodsRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_GET_AUTH_METHODS_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val typeString = request.data["type"] as? String
        val type = typeString?.let { value ->
            AuthenticationMethodType.values().firstOrNull { it.type == value }
        }

        client.getAuthenticationMethods(type)
            .start(object :
                Callback<List<AuthenticationMethod>, MyAccountException> {
                override fun onFailure(exception: MyAccountException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(
                    res: List<AuthenticationMethod>
                ) {
                    result.success(
                        res.map { it.toMyAccountMethodMap() }
                    )
                }
            })
    }
}
