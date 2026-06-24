package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountChallengeMap
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_ENROLL_EMAIL_METHOD =
    "myAccount#enrollEmail"

class EnrollEmailRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_ENROLL_EMAIL_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("email"), request.data)

        val email = request.data["email"] as String

        client.enrollEmail(email)
            .start(object :
                Callback<EnrollmentChallenge, MyAccountException> {
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
                    res: EnrollmentChallenge
                ) {
                    result.success(
                        res.toMyAccountChallengeMap()
                    )
                }
            })
    }
}
