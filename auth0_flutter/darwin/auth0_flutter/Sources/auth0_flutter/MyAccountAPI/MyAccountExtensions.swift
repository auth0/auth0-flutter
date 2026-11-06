import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

extension FlutterError {
    convenience init(from error: MyAccountError) {
        var details: [String: Any] = [
            "_statusCode": error.statusCode,
            "_title": error.title,
            "_detail": error.detail,
            "_errorFlags": [
                "isNetworkError": error.isNetworkError
            ]
        ]
        if let validationErrors = error.validationErrors {
            details["validation_errors"] = validationErrors.map { validationError -> [String: Any?] in
                return [
                    "detail": validationError.detail,
                    "field": validationError.field,
                    "pointer": validationError.pointer,
                    "source": validationError.source
                ]
            }
        }
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

#if MY_ACCOUNT_PROFILE
extension MyAccountProfile {
    func asDictionary() -> [String: Any?] {
        return [
            "user_id": userId,
            "given_name": givenName,
            "family_name": familyName,
            "name": name,
            "nickname": nickname,
            "picture": picture,
            "email": email,
            "email_verified": emailVerified,
            "phone_number": phoneNumber,
            "phone_verified": phoneVerified,
            "username": username,
            "created_at": createdAt,
            "updated_at": updatedAt,
            "profile_policy": profilePolicy?.mapValues { policy -> [String: Any?] in
                return [
                    "access": policy.access.rawValue,
                    "source": policy.source.rawValue,
                    "reason": policy.reason
                ]
            }
        ]
    }
}
#endif
