package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.request.GetUserProfileOptions
import com.auth0.android.result.MyAccountProfile
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountProfileMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_GET_USER_PROFILE_METHOD =
    "myAccount#getUserProfile"

class GetUserProfileRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_GET_USER_PROFILE_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        @Suppress("UNCHECKED_CAST")
        val fields = (request.data["fields"] as? List<String>) ?: emptyList()
        val includeFields = request.data["includeFields"] as? Boolean ?: true

        client.getUserProfile(GetUserProfileOptions(fields, includeFields))
            .start(object : Callback<MyAccountProfile, MyAccountException> {
                override fun onFailure(exception: MyAccountException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(res: MyAccountProfile) {
                    result.success(res.toMyAccountProfileMap())
                }
            })
    }
}
