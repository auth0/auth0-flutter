package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaVerifyException
import com.auth0.android.authentication.mfa.MfaVerificationType
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaCredentialsMap
import com.auth0.auth0_flutter.toMfaMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val MFA_VERIFY_METHOD = "mfa#verify"

class VerifyRequestHandler : MfaRequestHandler {
    override val method: String = MFA_VERIFY_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        assertHasProperties(listOf("grantType"), request.data)

        val type = when (val grantType = request.data["grantType"] as String) {
            "otp" -> {
                assertHasProperties(listOf("otp"), request.data)
                MfaVerificationType.Otp(request.data["otp"] as String)
            }
            "oob" -> {
                assertHasProperties(listOf("oobCode"), request.data)
                MfaVerificationType.Oob(
                    request.data["oobCode"] as String,
                    request.data["bindingCode"] as? String
                )
            }
            "recovery_code" -> {
                assertHasProperties(listOf("recoveryCode"), request.data)
                MfaVerificationType.RecoveryCode(request.data["recoveryCode"] as String)
            }
            else -> throw IllegalArgumentException("Unknown grantType: $grantType")
        }

        client.verify(type)
            .start(object : Callback<Credentials, MfaVerifyException> {
                override fun onFailure(exception: MfaVerifyException) {
                    result.error(
                        exception.getCode(),
                        exception.getDescription(),
                        exception.toMfaMap()
                    )
                }

                override fun onSuccess(res: Credentials) {
                    result.success(res.toMfaCredentialsMap())
                }
            })
    }
}
