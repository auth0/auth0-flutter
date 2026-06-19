package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaEnrollmentType
import com.auth0.android.authentication.mfa.MfaException.MfaEnrollmentException
import com.auth0.android.callback.Callback
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaEnrollmentMap
import com.auth0.auth0_flutter.toMfaMap
import io.flutter.plugin.common.MethodChannel

private const val MFA_ENROLL_TOTP_METHOD = "mfa#enrollTotp"

class EnrollTotpRequestHandler : MfaRequestHandler {
    override val method: String = MFA_ENROLL_TOTP_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        client.enroll(MfaEnrollmentType.Otp)
            .start(object : Callback<EnrollmentChallenge, MfaEnrollmentException> {
                override fun onFailure(exception: MfaEnrollmentException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMfaMap()
                    )
                }

                override fun onSuccess(res: EnrollmentChallenge) {
                    result.success(res.toMfaEnrollmentMap())
                }
            })
    }
}
