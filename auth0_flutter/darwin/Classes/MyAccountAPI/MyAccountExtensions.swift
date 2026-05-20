import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

extension FlutterError {
    convenience init(from error: MyAccountError) {
        let details: [String: Any] = [
            "_statusCode": error.statusCode,
            "_errorFlags": [
                "isNetworkError": false
            ]
        ]
        self.init(code: error.code,
                  message: error.detail.isEmpty ? error.title : error.detail,
                  details: details)
    }
}

extension AuthenticationMethod {
    func asDictionary() -> [String: Any?] {
        return [
            "id": id,
            "type": type,
            "name": name,
            "phone_number": phoneNumber,
            "email": nil,
            "totp_secret": nil,
            "totp_uri": nil,
            "preferred_authentication_method": preferredAuthenticationMethod,
            "created_at": createdAt,
            "last_auth_at": nil
        ]
    }
}

extension PhoneEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "id": authenticationId,
            "auth_session": authenticationSession,
            "totp_secret": nil,
            "totp_uri": nil,
            "barcode_uri": nil,
            "recovery_code": nil
        ]
    }
}

extension EmailEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "id": authenticationId,
            "auth_session": authenticationSession,
            "totp_secret": nil,
            "totp_uri": nil,
            "barcode_uri": nil,
            "recovery_code": nil
        ]
    }
}

extension TOTPEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "id": authenticationId,
            "auth_session": authenticationSession,
            "totp_secret": authenticatorManualInputCode,
            "totp_uri": authenticatorQRCodeURI,
            "barcode_uri": authenticatorQRCodeURI,
            "recovery_code": nil
        ]
    }
}

extension PushEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "id": authenticationId,
            "auth_session": authenticationSession,
            "totp_secret": nil,
            "totp_uri": nil,
            "barcode_uri": authenticatorQRCodeURI,
            "recovery_code": nil
        ]
    }
}

extension RecoveryCodeEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        return [
            "id": authenticationId,
            "auth_session": authenticationSession,
            "totp_secret": nil,
            "totp_uri": nil,
            "barcode_uri": nil,
            "recovery_code": recoveryCode
        ]
    }
}
