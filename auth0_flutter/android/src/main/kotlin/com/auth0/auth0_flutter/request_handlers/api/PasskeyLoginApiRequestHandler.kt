package com.auth0.auth0_flutter.request_handlers.api

private const val AUTH_PASSKEY_LOGIN_METHOD = "auth#passkeyLogin"

/**
 * Exchanges a passkey login assertion (presented by the app) and a login
 * challenge for Auth0 tokens by calling the `/oauth/token` endpoint. This
 * handler does not present any UI.
 *
 * The exchange is identical to signup; see [PasskeyTokenExchangeApiRequestHandler].
 */
class PasskeyLoginApiRequestHandler : PasskeyTokenExchangeApiRequestHandler() {
    override val method: String = AUTH_PASSKEY_LOGIN_METHOD
}
