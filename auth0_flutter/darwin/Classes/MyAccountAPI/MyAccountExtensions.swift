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
            "_title": error.title,
            "_detail": error.detail,
            "_errorFlags": [
                "isNetworkError": error.isNetworkError
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
            "last_auth_at": nil,
            "confirmed": confirmed,
            "usage": usage
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

#if PASSKEYS_PLATFORM
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension PasskeyEnrollmentChallenge {
    func asDictionary() -> [String: Any?] {
        // Forward the WebAuthn creation options in the flat shape the app's
        // platform-authenticator ceremony consumes, plus the authentication
        // method id needed to finish enrollment.
        return [
            "authenticationMethodId": authenticationMethodId,
            "authSession": authenticationSession,
            "authParamsPublicKey": [
                "challenge": challengeData.base64URLEncodedString(),
                "rpId": relyingPartyId,
                "userId": userId.base64URLEncodedString(),
                "userName": userName
            ]
        ]
    }
}

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension PasskeyAuthenticationMethod {
    func asDictionary() -> [String: Any?] {
        let createdAtFormatter = ISO8601DateFormatter()
        createdAtFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [
            "id": id,
            "type": type,
            "identity_user_id": userIdentityId,
            "user_agent": userAgent,
            "key_id": credential.id,
            "public_key": credential.publicKey.base64EncodedString(),
            "user_handle": credential.userHandle.base64URLEncodedString(),
            "credential_device_type": credential.deviceType.rawValue,
            "credential_backed_up": credential.isBackedUp,
            "aaguid": aaguid,
            "relying_party_id": relyingPartyIdentifier,
            "created_at": createdAtFormatter.string(from: createdAt)
        ]
    }
}
#endif
