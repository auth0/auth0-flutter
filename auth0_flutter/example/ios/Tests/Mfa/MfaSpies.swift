@testable import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - Spy MFAClient

class SpyMFAClient: MFAClient, @unchecked Sendable {
    var dpop: DPoP?
    var auth0ClientInfo = Auth0ClientInfo()
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
                    expiresAt: Date(timeIntervalSinceNow: 3600), scope: "openid")
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
                           factorsAllowed: [String]) -> any Requestable<[Authenticator], MfaListAuthenticatorsError> {
        calledGetAuthenticators = true
        getAuthenticatorsMfaTokenArg = mfaToken
        getAuthenticatorsFactorsArg = factorsAllowed
        return MockRequest(result: getAuthenticatorsResult)
    }

    func enroll(mfaToken: String, phoneNumber: String) -> any Requestable<MFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollPhone = true
        enrollPhoneNumberArg = phoneNumber
        return MockRequest(result: enrollPhoneResult)
    }

    func enroll(mfaToken: String, email: String) -> any Requestable<MFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollEmail = true
        enrollEmailArg = email
        return MockRequest(result: enrollEmailResult)
    }

    func enroll(mfaToken: String) -> any Requestable<OTPMFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollTotp = true
        return MockRequest(result: enrollTotpResult)
    }

    func enroll(mfaToken: String) -> any Requestable<PushMFAEnrollmentChallenge, MfaEnrollmentError> {
        calledEnrollPush = true
        return MockRequest(result: enrollPushResult)
    }

    func challenge(with authenticatorId: String,
                   mfaToken: String) -> any Requestable<MFAChallenge, MfaChallengeError> {
        calledChallenge = true
        challengeAuthenticatorIdArg = authenticatorId
        return MockRequest(result: challengeResult)
    }

    func verify(oobCode: String, bindingCode: String?,
                mfaToken: String) -> any TokenRequestable<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyOobCodeArg = oobCode
        verifyBindingCodeArg = bindingCode
        return MockTokenRequest(result: verifyResult)
    }

    func verify(otp: String, mfaToken: String) -> any TokenRequestable<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyOtpArg = otp
        return MockTokenRequest(result: verifyResult)
    }

    func verify(recoveryCode: String, mfaToken: String) -> any TokenRequestable<Credentials, MFAVerifyError> {
        calledVerify = true
        verifyRecoveryCodeArg = recoveryCode
        return MockTokenRequest(result: verifyResult)
    }
}
