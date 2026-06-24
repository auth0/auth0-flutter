@testable import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - Helper

private func makeAuthMethod(id: String = "test-id", type: String = "phone",
                            confirmed: Bool? = nil) -> AuthenticationMethod {
    AuthenticationMethod(type: type, credentialBackedUp: nil, credentialDeviceType: nil,
                         identityUserId: nil, keyId: nil, publicKey: nil, transports: nil,
                         userAgent: nil, userHandle: nil, lastPasswordReset: nil,
                         id: id, createdAt: "2026-01-01", usage: [],
                         confirmed: confirmed, name: nil,
                         preferredAuthenticationMethod: nil, phoneNumber: nil)
}

// MARK: - Spy MyAccount Authentication Methods

class SpyMyAccountAuthenticationMethods: MyAccountAuthenticationMethods {
    var url: URL { mockURL }
    var token: String { "test-token" }
    var telemetry = Telemetry()
    var logger: Logger?
    var dpop: DPoP?

    var getAuthMethodsResult: Result<[AuthenticationMethod], MyAccountError> = .success([])
    var getAuthMethodResult: Result<AuthenticationMethod, MyAccountError> = .success(makeAuthMethod())
    var deleteResult: Result<Void, MyAccountError> = .success(())
    var getFactorsResult: Result<[Factor], MyAccountError> = .success([])
    var enrollPhoneResult: Result<PhoneEnrollmentChallenge, MyAccountError> = .success(
        PhoneEnrollmentChallenge(authenticationId: "phone|test", authenticationSession: "session123")
    )
    var enrollEmailResult: Result<EmailEnrollmentChallenge, MyAccountError> = .success(
        EmailEnrollmentChallenge(authenticationId: "email|test", authenticationSession: "session123")
    )
    var enrollTOTPResult: Result<TOTPEnrollmentChallenge, MyAccountError> = .success(
        TOTPEnrollmentChallenge(authenticationId: "totp|test", authenticationSession: "session123",
                                authenticatorQRCodeURI: "otpauth://totp/test",
                                authenticatorManualInputCode: "SECRET123")
    )
    var enrollPushResult: Result<PushEnrollmentChallenge, MyAccountError> = .success(
        PushEnrollmentChallenge(authenticationId: "push|test", authenticationSession: "session123",
                                authenticatorQRCodeURI: "otpauth://push/test",
                                authenticatorManualInputCode: nil)
    )
    var enrollRecoveryResult: Result<RecoveryCodeEnrollmentChallenge, MyAccountError> = .success(
        RecoveryCodeEnrollmentChallenge(authenticationId: "recovery|test",
                                        authenticationSession: "session123",
                                        recoveryCode: "RECOVERY123")
    )
    var confirmResult: Result<AuthenticationMethod, MyAccountError> = .success(makeAuthMethod(confirmed: true))
    var updateResult: Result<AuthenticationMethod, MyAccountError> = .success(makeAuthMethod())

    var calledEnrollPasskeyChallenge = false
    var calledEnrollPasskey = false
    var enrollPasskeyChallengeUserIdentityIdArg: String?
    var enrollPasskeyChallengeConnectionArg: String?
    var enrollPasskeyChallengeShouldFail = false
    var enrollPasskeyShouldFail = false

    var calledGetAuthMethods = false
    var calledGetAuthMethod = false
    var calledDelete = false
    var calledGetFactors = false
    var calledEnrollPhone = false
    var calledEnrollEmail = false
    var calledEnrollTOTP = false
    var calledEnrollPush = false
    var calledEnrollRecovery = false
    var calledConfirm = false
    var calledUpdate = false

    var getAuthMethodIdArg: String?
    var getAuthMethodsTypeArg: AuthenticationMethodType?
    var deleteIdArg: String?
    var enrollPhoneNumberArg: String?
    var enrollPhoneMethodArg: PreferredAuthenticationMethod?
    var enrollEmailArg: String?
    var confirmIdArg: String?
    var confirmAuthSessionArg: String?
    var confirmOtpArg: String?
    var confirmEnrollmentFactorType: String?
    var updateIdArg: String?
    var updateNameArg: String?
    var updatePreferredArg: PreferredAuthenticationMethod?

    func getAuthenticationMethods(type: AuthenticationMethodType?) -> Request<[AuthenticationMethod], MyAccountError> {
        calledGetAuthMethods = true
        getAuthMethodsTypeArg = type
        return request(getAuthMethodsResult)
    }

    func updateAuthenticationMethod(by id: String,
                                    name: String?,
                                    preferredAuthenticationMethod: PreferredAuthenticationMethod?) -> Request<AuthenticationMethod, MyAccountError> {
        calledUpdate = true
        updateIdArg = id
        updateNameArg = name
        updatePreferredArg = preferredAuthenticationMethod
        return request(updateResult)
    }

    func getAuthenticationMethod(by id: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledGetAuthMethod = true
        getAuthMethodIdArg = id
        return request(getAuthMethodResult)
    }

    func deleteAuthenticationMethod(by id: String) -> Request<Void, MyAccountError> {
        calledDelete = true
        deleteIdArg = id
        return request(deleteResult)
    }

    func getFactors() -> Request<[Factor], MyAccountError> {
        calledGetFactors = true
        return request(getFactorsResult)
    }

    func enrollPhone(phoneNumber: String,
                     preferredAuthenticationMethod: PreferredAuthenticationMethod?) -> Request<PhoneEnrollmentChallenge, MyAccountError> {
        calledEnrollPhone = true
        enrollPhoneNumberArg = phoneNumber
        enrollPhoneMethodArg = preferredAuthenticationMethod
        return request(enrollPhoneResult)
    }

    func enrollEmail(emailAddress: String) -> Request<EmailEnrollmentChallenge, MyAccountError> {
        calledEnrollEmail = true
        enrollEmailArg = emailAddress
        return request(enrollEmailResult)
    }

    func enrollTOTP() -> Request<TOTPEnrollmentChallenge, MyAccountError> {
        calledEnrollTOTP = true
        return request(enrollTOTPResult)
    }

    func enrollPushNotification() -> Request<PushEnrollmentChallenge, MyAccountError> {
        calledEnrollPush = true
        return request(enrollPushResult)
    }

    func enrollRecoveryCode() -> Request<RecoveryCodeEnrollmentChallenge, MyAccountError> {
        calledEnrollRecovery = true
        return request(enrollRecoveryResult)
    }

    func confirmPhoneEnrollment(id: String, authSession: String,
                                otpCode: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledConfirm = true
        confirmIdArg = id
        confirmAuthSessionArg = authSession
        confirmOtpArg = otpCode
        confirmEnrollmentFactorType = "phone"
        return request(confirmResult)
    }

    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func passkeyEnrollmentChallenge(userIdentityId: String?,
                                    connection: String?) -> Request<PasskeyEnrollmentChallenge, MyAccountError> {
        calledEnrollPasskeyChallenge = true
        enrollPasskeyChallengeUserIdentityIdArg = userIdentityId
        enrollPasskeyChallengeConnectionArg = connection
        if enrollPasskeyChallengeShouldFail {
            return request(.failure(MyAccountError(info: [:], statusCode: 401)))
        }
        let challenge = PasskeyEnrollmentChallenge(
            authenticationMethodId: "passkey|test",
            authenticationSession: "session123",
            relyingPartyId: "example.com",
            userId: Data("user-id".utf8),
            userName: "john@example.com",
            challengeData: Data("challenge-data".utf8)
        )
        return request(.success(challenge))
    }

    @available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
    func enroll(passkey: NewPasskey,
                challenge: PasskeyEnrollmentChallenge) -> Request<PasskeyAuthenticationMethod, MyAccountError> {
        calledEnrollPasskey = true
        if enrollPasskeyShouldFail {
            return request(.failure(MyAccountError(info: [:], statusCode: 401)))
        }
        let credential = PasskeyCredential(
            id: "key-id",
            publicKey: Data("public-key".utf8),
            userHandle: Data("user-handle".utf8),
            deviceType: .multiDevice,
            isBackedUp: true
        )
        let method = PasskeyAuthenticationMethod(
            id: "passkey|test",
            type: "passkey",
            userIdentityId: "user-id",
            userAgent: "test-agent",
            credential: credential,
            createdAt: Date(timeIntervalSince1970: 0),
            aaguid: "aaguid",
            relyingPartyIdentifier: "example.com"
        )
        return request(.success(method))
    }

    func confirmTOTPEnrollment(id: String, authSession: String,
                               otpCode: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledConfirm = true
        confirmIdArg = id
        confirmAuthSessionArg = authSession
        confirmOtpArg = otpCode
        confirmEnrollmentFactorType = "totp"
        return request(confirmResult)
    }

    func confirmEmailEnrollment(id: String, authSession: String,
                                otpCode: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledConfirm = true
        confirmIdArg = id
        confirmAuthSessionArg = authSession
        confirmOtpArg = otpCode
        confirmEnrollmentFactorType = "email"
        return request(confirmResult)
    }

    func confirmPushNotificationEnrollment(id: String,
                                           authSession: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledConfirm = true
        confirmIdArg = id
        confirmAuthSessionArg = authSession
        confirmEnrollmentFactorType = "push-notification"
        return request(confirmResult)
    }

    func confirmRecoveryCodeEnrollment(id: String,
                                       authSession: String) -> Request<AuthenticationMethod, MyAccountError> {
        calledConfirm = true
        confirmIdArg = id
        confirmAuthSessionArg = authSession
        confirmEnrollmentFactorType = "recovery-code"
        return request(confirmResult)
    }
}

// MARK: - Spy MyAccount

class SpyMyAccount: MyAccount {
    static var apiVersion: String { "v1" }
    var url: URL { mockURL }
    var token: String { "test-token" }
    var telemetry = Telemetry()
    var logger: Logger?
    var dpop: DPoP?

    let spy: SpyMyAccountAuthenticationMethods
    var authenticationMethods: MyAccountAuthenticationMethods { spy }

    init(spy: SpyMyAccountAuthenticationMethods = SpyMyAccountAuthenticationMethods()) {
        self.spy = spy
    }
}

// MARK: - Request Helper

private extension SpyMyAccountAuthenticationMethods {
    func request<T>(_ result: Result<T, MyAccountError>) -> Request<T, MyAccountError> {
        Request(session: mockURLSession,
                url: url,
                method: "",
                handle: { _, callback in callback(result) },
                logger: nil,
                telemetry: telemetry)
    }
}
