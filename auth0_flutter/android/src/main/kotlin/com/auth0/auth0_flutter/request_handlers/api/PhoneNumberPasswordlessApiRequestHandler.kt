package com.auth0.auth0_flutter.request_handlers.api

import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.authentication.PasswordlessType
import com.auth0.android.callback.Callback
import com.auth0.auth0_flutter.request_handlers.MethodCallRequest
import com.auth0.auth0_flutter.toMap
import com.auth0.auth0_flutter.utils.assertHasProperties
import io.flutter.plugin.common.MethodChannel

private const val PASSWORDLESS_PHONE_NUMBER_LOGIN_METHOD = "auth#passwordlessWithPhoneNumber"

class PhoneNumberPasswordlessApiRequestHandler : ApiRequestHandler {
    override val method: String = PASSWORDLESS_PHONE_NUMBER_LOGIN_METHOD

    override fun handle(
        api: AuthenticationAPIClient,
        request: MethodCallRequest,
        result: MethodChannel.Result
    ) {
        val args = request.data
        assertHasProperties(listOf("phoneNumber", "passwordlessType"), args)
        val passwordlessType = getPasswordlessType(args["passwordlessType"] as String)

        val builder = api.passwordlessWithSMS(
            args["phoneNumber"] as String,
            passwordlessType
        )

        builder.start(object : Callback<Void?, AuthenticationException> {
            override fun onFailure(exception: AuthenticationException) {
                result.error(
                    exception.getCode(),
                    exception.getDescription(),
                    exception.toMap()
                )
            }

            override fun onSuccess(void: Void?) {
                result.success(void)
            }
        })
    }

    private fun getPasswordlessType(passwordlessType: String): PasswordlessType {
        return when (passwordlessType) {
            "code" -> PasswordlessType.CODE
            "link" -> PasswordlessType.WEB_LINK
            "link_android" -> PasswordlessType.ANDROID_LINK
            else -> PasswordlessType.CODE
        }
    }
}
