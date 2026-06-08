package com.auth0.auth0_flutter.request_handlers.api

private const val AUTH_PASSKEY_SIGNUP_METHOD = "auth#passkeySignup"

/**
 * Exchanges a passkey signup attestation (presented by the app) and a signup
 * challenge for Auth0 tokens by calling the `/oauth/token` endpoint. This
 * handler does not present any UI.
 *
 * The exchange is identical to login; see [PasskeyTokenExchangeApiRequestHandler].
 */
class PasskeySignupApiRequestHandler : PasskeyTokenExchangeApiRequestHandler() {
    override val method: String = AUTH_PASSKEY_SIGNUP_METHOD
}
