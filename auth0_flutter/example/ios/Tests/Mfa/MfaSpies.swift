@testable import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - Spy MFAClient

class SpyMFAClient: MFAClient {
    var dpop: DPoP?
    var telemetry = Telemetry()
    var logger: Logger?

    // MARK: Stubbed results

    var getAuthenticatorsResult: Result<[Authenticator], MfaListAuthenticatorsError> =
        .success([])
    var enrollPhoneResult: Result<MFAEnrollmentChallenge, MfaEnrollmentError> = .success(
        MFAEnrollmentChallenge(authenticatorType: "oob", bindingMethod: "prompt",
                               recoveryCodes: nil, oobChannel: "sms", oobCode: "oob-code")
    )
    var enrollEmailResult: Result<MFAEnrollmentChallenge, MfaEnrollmentError> = .success(
        MFAEnrollmentChallenge(authenticatorType: "oob", bindingMethod: "prompt",
                               recoveryCodes: nil, oobChannel: "email", oobCode: "oob-code")
    )
    var enrollTotpResult: Result<OTPMFAEnrollmentChallenge, MfaEnrollmentError> = .success(
        OTPMFAEnrollmentChallenge(authenticatorType: "otp", secret: "SECRET",
                                  barcodeUri: "otpauth://totp/test", recoveryCodes: ["r1"])
    )
    var enrollPushResult: Result<PushMFAEnrollmentChallenge, MfaEnrollmentError> = .success(
        PushMFAEnrollmentChallenge(authenticatorType: "oob", oobChannel: "auth0",
                                   oobCode: "oob-code", barcodeUri: "otpauth://push/test",
                                   recoveryCodes: nil)
    )
    var challengeResult: Result<MFAChallenge, MfaChallengeError> = .success(
        MFAChallenge(challengeType: "oob", oobCode: "oob-code", bindingMethod: "prompt")
    )
    var verifyResult: Result<Credentials, MFAVerifyError> = .success(
        Credentials(accessToken: "access-token", tokenType: "Bearer",
                    idToken: testIdToken, refreshToken: "refresh-token",
                    expiresIn: Date(timeIntervalSinceNow: 3600), scope: "openid")
    )

    // MARK: Spied args

    var calledGetAuthenticators = false
    var getAuthenticatorsMfaTokenArg: String?
    var getAuthenticatorsFactorsArg: [String]?
    var calledEnrollPhone = false
    var enrollPhoneNumberArg: String?
    var calledEnrollEmail = false
    var enrollEmailArg: String?
    var calledEnrollTotp = false
    var calledEnrollPush = false
    var calledChallenge = false
    var challengeAuthenticatorIdArg: String?
    var calledVerify = false
    var verifyOtpArg: String?
    var verifyOobCodeArg: String?
    var verifyBindingCodeArg: String?
    var verifyRecoveryCodeArg: String?

    func getAuthenticators(mfaToken: String,
                           factorsAllowed: [String]) -> Request<[Authenticator], MfaListAuthenticatorsError> {
        calledGetAuthenticators = true
        getAuthenticatorsMfaTokenArg = mfaToken
        getAuthenticatorsFactorsArg = factorsAllowed
        return request(getAuthenticatorsResult)
    }

    func enroll(mfaToken: String, phoneNumber: String) -> Request<MFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollPhone = true
        enrollPhoneNumberArg = phoneNumber
        return request(enrollPhoneResult)
    }

    func enroll(mfaToken: String, email: String) -> Request<MFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollEmail = true
        enrollEmailArg = email
        return request(enrollEmailResult)
    }

    func enroll(mfaToken: String) -> Request<OTPMFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollTotp = true
        return request(enrollTotpResult)
    }

    func enroll(mfaToken: String) -> Request<PushMFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollPush = true
        return request(enrollPushResult)
    }

    func challenge(with authenticatorId: String,
                   mfaToken: String) -> Request<MFAChallenge, MfaChallengeError> {
        calledChallenge = true
        challengeAuthenticatorIdArg = authenticatorId
        return request(challengeResult)
    }

    func verify(oobCode: String, bindingCode: String?,
                mfaToken: String) -> Request<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyOobCodeArg = oobCode
        verifyBindingCodeArg = bindingCode
        return request(verifyResult)
    }

    func verify(otp: String, mfaToken: String) -> Request<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyOtpArg = otp
        return request(verifyResult)
    }

    func verify(recoveryCode: String, mfaToken: String) -> Request<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyRecoveryCodeArg = recoveryCode
        return request(verifyResult)
    }
}

// MARK: - Request Helper

private extension SpyMFAClient {
    func request<T>(_ result: Result<T, MfaListAuthenticatorsError>) -> Request<T, MfaListAuthenticatorsError> {
        Request(session: mockURLSession, url: mockURL, method: "",
                handle: { _, callback in callback(result) }, logger: nil, telemetry: telemetry)
    }

    func request<T>(_ result: Result<T, MfaEnrollmentError>) -> Request<T, MfaEnrollmentError> {
        Request(session: mockURLSession, url: mockURL, method: "",
                handle: { _, callback in callback(result) }, logger: nil, telemetry: telemetry)
    }

    func request<T>(_ result: Result<T, MfaChallengeError>) -> Request<T, MfaChallengeError> {
        Request(session: mockURLSession, url: mockURL, method: "",
                handle: { _, callback in callback(result) }, logger: nil, telemetry: telemetry)
    }

    func request<T>(_ result: Result<T, MFAVerifyError>) -> Request<T, MFAVerifyError> {
        Request(session: mockURLSession, url: mockURL, method: "",
                handle: { _, callback in callback(result) }, logger: nil, telemetry: telemetry)
    }
}
