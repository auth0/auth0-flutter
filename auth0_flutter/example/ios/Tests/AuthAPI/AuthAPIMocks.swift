@testable import Auth0

class MockAuthentication: Authentication {
    let clientId: String
    let url: URL
    var telemetry: Telemetry
    var logger: Logger?

    var credentialsResult: AuthenticationResult<Credentials> = .success(Credentials())
    var databaseUserResult: AuthenticationResult<DatabaseUser> = .success((email: "foo", username: nil, verified: true))
    var userInfoResult: AuthenticationResult<UserInfo> = .success(UserInfo(json: ["sub": "foo"])!)
    var voidResult: AuthenticationResult<Void> = .success(())

    init(clientId: String, url: URL, telemetry: Telemetry) {
        self.clientId = clientId
        self.url = url
        self.telemetry = telemetry
    }

    func login(usernameOrEmail username: String,
               password: String,
               realmOrConnection realm: String,
               audience: String?,
               scope: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func login(withOTP otp: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func login(withRecoveryCode recoveryCode: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func signup(email: String,
                username: String?,
                password: String,
                connection: String,
                userMetadata: [String: Any]?,
                rootAttributes: [String: Any]?) -> Request<DatabaseUser, AuthenticationError> {
        return request(databaseUserResult)
    }

    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError> {
        return request(voidResult)
    }

    func userInfo(withAccessToken accessToken: String) -> Request<UserInfo, AuthenticationError> {
        return request(userInfoResult)
    }

    func codeExchange(withCode code: String,
                      codeVerifier: String,
                      redirectURI: String) -> Request<Credentials, AuthenticationError> {
        return request(credentialsResult)
    }

    func revoke(refreshToken: String) -> Request<Void, AuthenticationError> {
        return request(voidResult)
    }

    func jwks() -> Request<JWKS, AuthenticationError> {
        return request()
    }
}

private extension MockAuthentication {
    func request<T>(_ result: AuthenticationResult<T>) -> Request<T, AuthenticationError> {
        Request(session: URLSession.shared,
                url: url,
                method: "GET",
                handle: {_, callback in callback(result)},
                logger: nil,
                telemetry: telemetry)
    }

    func request<T>() -> Request<T, AuthenticationError> {
        Request(session: URLSession.shared,
                url: url,
                method: "GET",
                handle: {_,_ in},
                logger: nil,
                telemetry: telemetry)
    }
}
