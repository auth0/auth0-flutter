package com.auth0.auth0_flutter.request_handlers.my_account

import com.auth0.android.callback.Callback
import com.auth0.android.myaccount.MyAccountAPIClient
import com.auth0.android.myaccount.MyAccountException
import com.auth0.android.myaccount.PhoneAuthenticationMethodType
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMyAccountChallengeMap
import com.auth0.auth0_flutter.toMyAccountMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MY_ACCOUNT_ENROLL_PHONE_METHOD =
    "myAccount#enrollPhone"

class EnrollPhoneRequestHandler : MyAccountRequestHandler {
    override val method: String = MY_ACCOUNT_ENROLL_PHONE_METHOD

    override fun handle(
        client: MyAccountAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(
            listOf("phoneNumber", "type"), request.data
        )

        val phoneNumber = request.data["phoneNumber"] as String
        val typeString = request.data["type"] as String
        val type = when (typeString) {
            "voice" -> PhoneAuthenticationMethodType.VOICE
            else -> PhoneAuthenticationMethodType.SMS
        }

        client.enrollPhone(phoneNumber, type)
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
