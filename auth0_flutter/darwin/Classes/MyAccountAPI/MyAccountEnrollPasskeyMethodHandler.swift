#if PASSKEYS_PLATFORM
import Auth0
import AuthenticationServices

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// A ``NewPasskey`` reconstructed from a credential map supplied by the app
/// (for example, from `ASAuthorizationController`).
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
private struct ReconstructedNewPasskey: NewPasskey {
    let credentialID: Data
    let attachment: ASAuthorizationPublicKeyCredentialAttachment
    let rawClientDataJSON: Data
    let rawAttestationObject: Data?
}

/// Enrolls an app-supplied passkey credential (a signup attestation) against a
/// previously obtained enrollment challenge via the My Account API. This is the
/// last part of the enrollment flow. This handler does not present any UI.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct MyAccountEnrollPasskeyMethodHandler: MethodHandler {
    enum Argument: String {
        case challenge
        case credential
    }

    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let challengeMap = arguments[Argument.challenge.rawValue] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.challenge.rawValue)))
        }
        guard let credentialMap = arguments[Argument.credential.rawValue] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.credential.rawValue)))
        }

        guard let challenge = Self.reconstructChallenge(from: challengeMap) else {
            return callback(FlutterError(code: "PASSKEY_ERROR",
                                         message: "Failed to reconstruct enrollment challenge",
                                         details: nil))
        }
        guard let passkey = Self.reconstructPasskey(from: credentialMap) else {
            return callback(FlutterError(code: "PASSKEY_ERROR",
                                         message: "Failed to reconstruct passkey credential",
                                         details: nil))
        }

        client
            .authenticationMethods
            .enroll(passkey: passkey, challenge: challenge)
            .start {
                switch $0 {
                case let .success(method):
                    callback(method.asDictionary())
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }

    // MARK: - Reconstruction

    private static func reconstructChallenge(
        from challengeMap: [String: Any]) -> PasskeyEnrollmentChallenge? {
        guard let authenticationMethodId = challengeMap["authenticationMethodId"] as? String,
              let authSession = challengeMap["authSession"] as? String,
              let authParamsPublicKey = challengeMap["authParamsPublicKey"] as? [String: Any],
              let challengeString = authParamsPublicKey["challenge"] as? String,
              let relyingPartyId = authParamsPublicKey["rpId"] as? String,
              let userIdString = authParamsPublicKey["userId"] as? String,
              let userName = authParamsPublicKey["userName"] as? String else {
            return nil
        }

        // `PasskeyEnrollmentChallenge`'s memberwise initializer is internal to
        // Auth0.swift, so reconstruct it the way the SDK itself does: decode
        // from the WebAuthn JSON with the authentication method id supplied via
        // the `locationHeader` decoder userInfo key.
        let challengeJson: [String: Any] = [
            "auth_session": authSession,
            "authn_params_public_key": [
                "rp": ["id": relyingPartyId],
                "user": ["id": userIdString, "name": userName],
                "challenge": challengeString
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: challengeJson) else {
            return nil
        }

        let decoder = JSONDecoder()
        // Matches Auth0.swift's internal `CodingUserInfoKey.locationHeaderKey`,
        // whose raw value is "locationHeader". The decoder reads the last path
        // component as the authentication method id.
        if let locationHeaderKey = CodingUserInfoKey(rawValue: "locationHeader") {
            decoder.userInfo[locationHeaderKey] = authenticationMethodId
        }
        return try? decoder.decode(PasskeyEnrollmentChallenge.self, from: jsonData)
    }

    private static func reconstructPasskey(
        from credentialMap: [String: Any]) -> NewPasskey? {
        guard let credentialIdString = credentialMap["rawId"] as? String
                ?? credentialMap["id"] as? String,
              let credentialID = Data.fromBase64URLEncoded(credentialIdString),
              let response = credentialMap["response"] as? [String: Any],
              let clientDataString = response["clientDataJSON"] as? String,
              let rawClientDataJSON = Data.fromBase64URLEncoded(clientDataString),
              let attestationString = response["attestationObject"] as? String,
              let rawAttestationObject = Data.fromBase64URLEncoded(attestationString) else {
            return nil
        }

        let attachment: ASAuthorizationPublicKeyCredentialAttachment =
            (credentialMap["authenticatorAttachment"] as? String) == "crossPlatform"
                ? .crossPlatform : .platform

        return ReconstructedNewPasskey(
            credentialID: credentialID,
            attachment: attachment,
            rawClientDataJSON: rawClientDataJSON,
            rawAttestationObject: rawAttestationObject
        )
    }
}
#endif
