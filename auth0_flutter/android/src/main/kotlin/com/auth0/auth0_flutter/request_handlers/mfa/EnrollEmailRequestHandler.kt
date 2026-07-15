package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaEnrollmentType
import com.auth0.android.authentication.mfa.MfaException.MfaEnrollmentException
import com.auth0.android.callback.Callback
import com.auth0.android.result.EnrollmentChallenge
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaEnrollmentMap
import com.auth0.auth0_flutter.toMfaMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MFA_ENROLL_EMAIL_METHOD = "mfa#enrollEmail"

class EnrollEmailRequestHandler : MfaRequestHandler {
    override val method: String = MFA_ENROLL_EMAIL_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("email"), request.data)
        val email = request.data["email"] as String

        client.enroll(MfaEnrollmentType.Email(email))
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
