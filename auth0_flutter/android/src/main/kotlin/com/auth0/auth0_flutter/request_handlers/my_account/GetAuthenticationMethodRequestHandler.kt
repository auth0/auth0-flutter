package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.AuthenticationMethod
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountMethodMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_GET_AUTH_METHOD_METHOD =
    "myAccount#getAuthenticationMethod"

class GetAuthenticationMethodRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_GET_AUTH_METHOD_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("id"), request.data)

        val id = request.data["id"] as String

        client.getAuthenticationMethodById(id)
            .start(object :
                Callback<AuthenticationMethod, MyAccountException> {
                override fun onFailure(exception: MyAccountException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(res: AuthenticationMethod) {
                    result.success(res.toMyAccountMethodMap())
                }
            })
    }
}
