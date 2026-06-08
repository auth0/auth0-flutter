#if PASSKEYS_PLATFORM
import Auth0
import AuthenticationServices

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// A ``SignupPasskey`` reconstructed from a credential map supplied by the app
/// (for example, from `ASAuthorizationController`).
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
private struct ReconstructedSignupPasskey: SignupPasskey {
    let credentialID: Data
    let attachment: ASAuthorizationPublicKeyCredentialAttachment
    let rawClientDataJSON: Data
    let rawAttestationObject: Data?
}

/// Exchanges a passkey credential (presented by the app) and a signup challenge
/// for Auth0 tokens by calling the `/oauth/token` endpoint. This handler does
/// not present any UI.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct AuthAPIPasskeySignupMethodHandler: MethodHandler {
    enum Argument: String {
        case challenge
        case credential
        case connection
        case audience
        case scopes
        case organization
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let challengeMap = arguments[Argument.challenge.rawValue] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.challenge.rawValue)))
        }
        guard let credentialMap = arguments[Argument.credential.rawValue] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.credential.rawValue)))
        }

        guard let challenge = Self.reconstructChallenge(from: challengeMap) else {
            return callback(FlutterError(code: "PASSKEY_ERROR",
                                         message: "Failed to reconstruct signup challenge",
                                         details: nil))
        }
        guard let passkey = Self.reconstructPasskey(from: credentialMap) else {
            return callback(FlutterError(code: "PASSKEY_ERROR",
                                         message: "Failed to reconstruct passkey credential",
                                         details: nil))
        }

        let connection = arguments[Argument.connection.rawValue] as? String
        let audience = arguments[Argument.audience.rawValue] as? String
        let scopes = (arguments[Argument.scopes.rawValue] as? [String]) ?? []
        let organization = arguments[Argument.organization.rawValue] as? String
        let parameters = (arguments[Argument.parameters.rawValue] as? [String: Any]) ?? [:]

        client
            .login(passkey: passkey,
                   challenge: challenge,
                   connection: connection,
                   audience: audience,
                   scope: scopes.asSpaceSeparatedString,
                   organization: organization)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials):
                    callback(self.result(from: credentials))
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }

    // MARK: - Private

    static func reconstructChallenge(
        from challengeMap: [String: Any]) -> PasskeySignupChallenge? {
        guard let authParamsPublicKey = challengeMap["authParamsPublicKey"] as? [String: Any],
              let authSession = challengeMap["authSession"] as? String,
              let challengeString = authParamsPublicKey["challenge"] as? String,
              let relyingPartyId = authParamsPublicKey["rpId"] as? String,
              let userId = authParamsPublicKey["userId"] as? String,
              let userName = authParamsPublicKey["userName"] as? String else {
            return nil
        }

        let challengeJson: [String: Any] = [
            "auth_session": authSession,
            "authn_params_public_key": [
                "rp": ["id": relyingPartyId],
                "user": ["id": userId, "name": userName],
                "challenge": challengeString
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: challengeJson) else {
            return nil
        }
        return try? JSONDecoder().decode(PasskeySignupChallenge.self, from: jsonData)
    }

    static func reconstructPasskey(
        from credentialMap: [String: Any]) -> SignupPasskey? {
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

        return ReconstructedSignupPasskey(
            credentialID: credentialID,
            attachment: attachment,
            rawClientDataJSON: rawClientDataJSON,
            rawAttestationObject: rawAttestationObject
        )
    }
}
#endif
