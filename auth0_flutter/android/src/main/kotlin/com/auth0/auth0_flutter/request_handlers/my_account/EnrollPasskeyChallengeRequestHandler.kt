package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.result.PasskeyEnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.toMyAccountPasskeyChallengeMap
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_ENROLL_PASSKEY_CHALLENGE_METHOD =
    "myAccount#enrollPasskeyChallenge"

class EnrollPasskeyChallengeRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_ENROLL_PASSKEY_CHALLENGE_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val userIdentityId = request.data["userIdentityId"] as? String
        val connection = request.data["connection"] as? String

        client.passkeyEnrollmentChallenge(userIdentityId, connection)
            .start(object :
                Callback<PasskeyEnrollmentChallenge, MyAccountException> {
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
                    res: PasskeyEnrollmentChallenge
                ) {
                    result.success(res.toMyAccountPasskeyChallengeMap())
                }
            })
    }
}
