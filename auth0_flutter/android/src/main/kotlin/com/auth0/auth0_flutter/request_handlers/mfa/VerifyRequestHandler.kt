package com.auth0.auth0_flutter.request_handlers.mfa

import com.auth0.android.authentication.mfa.MfaApiClient
import com.auth0.android.authentication.mfa.MfaException.MfaVerifyException
import com.auth0.android.authentication.mfa.MfaVerificationType
import com.auth0.android.callback.Callback
import com.auth0.android.result.Credentials
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMfaCredentialsMap
import com.auth0.auth0_flutter.toMfaMap
import io.flutter.plugin.common.MethodChannel

private const val MFA_VERIFY_METHOD = "mfa#verify"

class VerifyRequestHandler : MfaRequestHandler {
    override val method: String = MFA_VERIFY_METHOD

    override fun handle(
        client: MfaApiClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val grantType = request.data["grantType"] as? String
            ?: throw IllegalArgumentException("Required property 'grantType' must be a string.")

        val type = when (grantType) {
            "otp" -> {
                val otp = request.data["otp"] as? String
                    ?: throw IllegalArgumentException("Required property 'otp' must be a string.")
                MfaVerificationType.Otp(otp)
            }
            "oob" -> {
                val oobCode = request.data["oobCode"] as? String
                    ?: throw IllegalArgumentException("Required property 'oobCode' must be a string.")
                MfaVerificationType.Oob(
                    oobCode,
                    request.data["bindingCode"] as? String
                )
            }
            "recovery_code" -> {
                val recoveryCode = request.data["recoveryCode"] as? String
                    ?: throw IllegalArgumentException("Required property 'recoveryCode' must be a string.")
                MfaVerificationType.RecoveryCode(recoveryCode)
            }
            else -> throw IllegalArgumentException("Unknown grantType: $grantType")
        }

        val verifyRequest = client.verify(type)

        val scopes = (request.data["scopes"] ?: arrayListOf<String>()) as ArrayList<*>
        if (scopes.isNotEmpty()) {
            verifyRequest.addParameter("scope", scopes.joinToString(separator = " "))
        }
        if (request.data["audience"] is String) {
            verifyRequest.addParameter("audience", request.data["audience"] as String)
        }

        verifyRequest
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
