@testable import Auth0

fileprivate let mockCredentials = Credentials()
fileprivate let mockChallenge = Challenge(challengeType: "", oobCode: nil, bindingMethod: nil)
fileprivate let mockDatabaseUser: DatabaseUser = (email: "", username: nil, verified: true)
fileprivate let mockUserInfo = UserInfo(json: ["sub": ""])!
fileprivate let mockSSOCredentials = SSOCredentials(
    sessionTransferToken: "token",
    issuedTokenType: "type",
    expiresIn: Date(),
    idToken: testIdToken,
    refreshToken: nil
)

class SpyAuthentication: Authentication {
    let clientId = ""
    let url = mockURL
    var telemetry = Telemetry()
    var logger: Logger?
    var sender: String = "auth0-flutter"
    var dpop: DPoP?

    var credentialsResult: AuthenticationResult<Credentials> = .success(mockCredentials)
    var ssoCredentialsResult: AuthenticationResult<SSOCredentials> = .success(mockSSOCredentials)
    var challengeResult: AuthenticationResult<Challenge> = .success(mockChallenge)
    var databaseUserResult: AuthenticationResult<DatabaseUser> = .success(mockDatabaseUser)
    var userInfoResult: AuthenticationResult<UserInfo> = .success(mockUserInfo)
    var voidResult: AuthenticationResult<Void> = .success(())
    var calledLoginWithUsernameOrEmail = false
    var calledLoginWithOTP = false
    var calledMultifactorChallenge = false
    var calledSignup = false
    var calledUserInfo = false
    var calledRenew = false
    var calledResetPassword = false
    var calledPasskeyLoginChallenge = false
    var calledLoginWithPasskey = false
    #if PASSKEYS_PLATFORM
    private var _passkeyLoginChallengeResultOverride: Any?
    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    var passkeyLoginChallengeResultOverride: AuthenticationResult<PasskeyLoginChallenge>? {
        get { _passkeyLoginChallengeResultOverride as? AuthenticationResult<PasskeyLoginChallenge> }
        set { _passkeyLoginChallengeResultOverride = newValue }
    }
    #endif
    var arguments: [String: Any] = [:]

    init() {}

    func login(usernameOrEmail username: String,
               password: String,
               realmOrConnection realm: String,
               audience: String?,
               scope: String) -> Request<Credentials, AuthenticationError> {
        arguments["usernameOrEmail"] = username
        arguments["password"] = password
        arguments["connectionOrRealm"] = realm
        arguments["audience"] = audience
        arguments["scope"] = scope
        calledLoginWithUsernameOrEmail = true
        return request(credentialsResult)
    }

    func login(withOTP otp: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        arguments["otp"] = otp
        arguments["mfaToken"] = mfaToken
        calledLoginWithOTP = true
        return request(credentialsResult)
    }

    func login(withRecoveryCode recoveryCode: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func multifactorChallenge(mfaToken: String,
                              types: [String]?,
                              authenticatorId: String?) -> Request<Challenge, AuthenticationError> {
        arguments["mfaToken"] = mfaToken
        arguments["types"] = types
        arguments["authenticatorId"] = authenticatorId
        calledMultifactorChallenge = true
        return request(challengeResult)
    }

    func signup(email: String,
                username: String?,
                password: String,
                connection: String,
                userMetadata: [String: Any]?,
                rootAttributes: [String: Any]?) -> Request<DatabaseUser, AuthenticationError> {
        arguments["email"] = email
        arguments["username"] = username
        arguments["password"] = password
        arguments["connection"] = connection
        arguments["username"] = username
        arguments["userMetadata"] = userMetadata
        calledSignup = true
        return request(databaseUserResult)
    }

    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError> {
        arguments["email"] = email
        arguments["connection"] = connection
        calledResetPassword = true
        return request(voidResult)
    }

    func userInfo(withAccessToken accessToken: String, tokenType: String) -> Request<UserInfo, AuthenticationError> {
        arguments["accessToken"] = accessToken
        arguments["tokenType"] = tokenType
        calledUserInfo = true
        return request(userInfoResult)
    }

    func codeExchange(withCode code: String,
                      codeVerifier: String,
                      redirectURI: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }
    
    func renew(withRefreshToken refreshToken: String, audience: String?, scope: String?) -> Request<Credentials, AuthenticationError> {
        arguments["refreshToken"] = refreshToken
        arguments["scope"] = scope
        arguments["audience"] = audience
        calledRenew = true
        return request(credentialsResult)
    }

    func ssoExchange(withRefreshToken refreshToken: String) -> Request<SSOCredentials, AuthenticationError> {
        arguments["refreshToken"] = refreshToken
        return request(ssoCredentialsResult)
    }

    func revoke(refreshToken: String) -> Request<Void, AuthenticationError> {
        return request(voidResult)
    }

    func jwks() -> Request<JWKS, AuthenticationError> {
        return request(.success(JWKS(keys: [])))
    }

    #if PASSKEYS_PLATFORM
    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func passkeyLoginChallenge(connection: String?,
                               organization: String?) -> Request<PasskeyLoginChallenge, AuthenticationError> {
        arguments["connection"] = connection
        arguments["organization"] = organization
        calledPasskeyLoginChallenge = true
        return request(passkeyLoginChallengeResultOverride
            ?? SpyAuthentication.passkeyLoginChallengeResult)
    }

    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func login(passkey: LoginPasskey,
               challenge: PasskeyLoginChallenge,
               connection: String?,
               audience: String?,
               scope: String,
               organization: String?) -> Request<Credentials, AuthenticationError> {
        arguments["connection"] = connection
        arguments["audience"] = audience
        arguments["scope"] = scope
        arguments["organization"] = organization
        calledLoginWithPasskey = true
        return request(credentialsResult)
    }

    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func login(passkey: SignupPasskey,
               challenge: PasskeySignupChallenge,
               connection: String?,
               audience: String?,
               scope: String,
               organization: String?) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func passkeySignupChallenge(email: String?,
                                phoneNumber: String?,
                                username: String?,
                                name: String?,
                                connection: String?,
                                organization: String?) -> Request<PasskeySignupChallenge, AuthenticationError> {
        return request(.failure(AuthenticationError(info: [:], statusCode: 0)))
    }
    #endif
}

#if PASSKEYS_PLATFORM
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension SpyAuthentication {
    /// A decoded `PasskeyLoginChallenge` for use as a spy result. The type only
    /// exposes a `Decodable` initializer, so it is built from JSON.
    static var passkeyLoginChallengeResult: AuthenticationResult<PasskeyLoginChallenge> {
        let json = """
        {
            "auth_session": "test-auth-session",
            "authn_params_public_key": {
                "rpId": "test-rp-id",
                "challenge": "dGVzdC1jaGFsbGVuZ2U"
            }
        }
        """.data(using: .utf8)!
        // swiftlint:disable:next force_try
        let challenge = try! JSONDecoder().decode(PasskeyLoginChallenge.self, from: json)
        return .success(challenge)
    }
}
#endif

private extension SpyAuthentication {
    func request<T>(_ result: AuthenticationResult<T>) -> Request<T, AuthenticationError> {
        Request(session: mockURLSession,
                url: url,
                method: "",
                handle: {_, callback in callback(result)},
                logger: nil,
                telemetry: telemetry)
    }
}
