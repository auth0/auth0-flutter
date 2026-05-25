package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.Factor
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_GET_FACTORS_METHOD =
    "myAccount#getFactors"

class GetFactorsRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_GET_FACTORS_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        client.getFactors()
            .start(object :
                Callback<List<Factor>, MyAccountException> {
                override fun onFailure(exception: MyAccountException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(res: List<Factor>) {
                    result.success(res.map {
                        mapOf(
                            "type" to it.type,
                            "usage" to it.usage
                        )
                    })
                }
            })
    }
}
