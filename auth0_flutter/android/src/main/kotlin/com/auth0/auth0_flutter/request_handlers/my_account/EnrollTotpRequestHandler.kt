package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.TotpEnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountChallengeMap
import com.auth0.auth0_flutter.toMyAccountMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_ENROLL_TOTP_METHOD =
    "myAccount#enrollTotp"

class EnrollTotpRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_ENROLL_TOTP_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        client.enrollTotp()
            .start(object :
                Callback<TotpEnrollmentChallenge, MyAccountException> {
                override fun onFailure(
                    exception: MyAccountException
                ) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMyAccountMap()
                    )
                }

                override fun onSuccess(
                    res: TotpEnrollmentChallenge
                ) {
                    result.success(
                        res.toMyAccountChallengeMap()
                    )
                }
            })
    }
}
