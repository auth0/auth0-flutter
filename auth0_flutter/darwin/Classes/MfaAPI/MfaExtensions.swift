import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

extension FlutterError {
    convenience init(from error: MfaListAuthenticatorsError) {
        self.init(fromMfaInfo: error.info, code: error.code, statusCode: error.statusCode)
    }

    convenience init(from error: MfaEnrollmentError) {
        self.init(fromMfaInfo: error.info, code: error.code, statusCode: error.statusCode)
    }

    convenience init(from error: MfaChallengeError) {
        self.init(fromMfaInfo: error.info, code: error.code, statusCode: error.statusCode)
    }

    convenience init(from error: MFAVerifyError) {
        self.init(fromMfaInfo: error.info, code: error.code, statusCode: error.statusCode)
    }

    private convenience init(fromMfaInfo info: [String: Any], code: String, statusCode: Int) {
        let isNetworkError = (info["cause"] as? Error) != nil
        let description = info["error_description"] as? String
            ?? info["description"] as? String
            ?? code
        let details: [String: Any] = [
            "_statusCode": statusCode,
            "_errorFlags": [
                "isNetworkError": isNetworkError
            ]
        ]
        self.init(code: code, message: description, details: details)
    }
}

extension Authenticator {
    func asDictionary() -> [String: Any?] {
        return [
            "id": id,
            "type": type,
            "authenticator_type": authenticatorType,
            "active": active,
            "oob_channel": oobChannel,
            "name": name
        ]
    }
}

extension MFAChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "challenge_type": challengeType,
            "oob_code": oobCode,
            "binding_method": bindingMethod
        ]
    }
}

extension MFAEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "authenticator_type": authenticatorType,
            "oob_channel": oobChannel,
            "oob_code": oobCode,
            "binding_method": bindingMethod,
            "totp_secret": nil,
            "barcode_uri": nil,
            "recovery_codes": recoveryCodes,
            "id": nil,
            "auth_session": nil
        ]
    }
}

extension OTPMFAEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "authenticator_type": authenticatorType,
            "oob_channel": nil,
            "oob_code": nil,
            "binding_method": nil,
            "totp_secret": secret,
            "barcode_uri": barcodeUri,
            "recovery_codes": recoveryCodes,
            "id": nil,
            "auth_session": nil
        ]
    }
}

extension PushMFAEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "authenticator_type": authenticatorType,
            "oob_channel": oobChannel,
            "oob_code": oobCode,
            "binding_method": nil,
            "totp_secret": nil,
            "barcode_uri": barcodeUri,
            "recovery_codes": recoveryCodes,
            "id": nil,
            "auth_session": nil
        ]
    }
}
