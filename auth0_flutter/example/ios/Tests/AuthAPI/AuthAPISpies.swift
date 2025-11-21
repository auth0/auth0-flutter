@testable import Auth0

fileprivate let mockCredentials = Credentials()
fileprivate let mockChallenge = Challenge(challengeType: "", oobCode: nil, bindingMethod: nil)
fileprivate let mockDatabaseUser: DatabaseUser = (email: "", username: nil, verified: true)
fileprivate let mockUserInfo = UserInfo(json: ["sub": ""])!
fileprivate let mockSSOCredentials = SSOCredentials()

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

    func userInfo(withAccessToken accessToken: String) -> Request<UserInfo, AuthenticationError> {
        arguments["accessToken"] = accessToken
        calledUserInfo = true
        return request(userInfoResult)
    }

    func codeExchange(withCode code: String,
                      codeVerifier: String,
                      redirectURI: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func renew(withRefreshToken refreshToken: String, scope: String?) -> Request<Credentials, AuthenticationError> {
        arguments["refreshToken"] = refreshToken
        arguments["scope"] = scope
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
}

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
