package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.request.UpdateUserProfileRequest
import com.auth0.android.result.MyAccountProfile
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountProfileMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_UPDATE_USER_PROFILE_METHOD =
    "myAccount#updateUserProfile"

class UpdateUserProfileRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_UPDATE_USER_PROFILE_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val profileRequest = UpdateUserProfileRequest(
            givenName = request.data["givenName"] as? String,
            familyName = request.data["familyName"] as? String,
            name = request.data["name"] as? String,
            nickname = request.data["nickname"] as? String,
            picture = request.data["picture"] as? String
        )

        client.updateUserProfile(profileRequest)
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
