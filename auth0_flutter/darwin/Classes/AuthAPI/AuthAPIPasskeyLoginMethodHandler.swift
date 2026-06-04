#if PASSKEYS_PLATFORM
import Auth0
import AuthenticationServices

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// A ``LoginPasskey`` reconstructed from a credential map provided by the
/// Flutter layer (the app presents the OS passkey UI and passes the resulting
/// assertion).
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
private struct ReconstructedLoginPasskey: LoginPasskey {
    let userID: Data!
    let credentialID: Data
    let attachment: ASAuthorizationPublicKeyCredentialAttachment
    let rawClientDataJSON: Data
    let rawAuthenticatorData: Data!
    let signature: Data!
}

/// Exchanges a passkey credential (presented by the app) and a login challenge
/// for Auth0 tokens by calling the `/oauth/token` endpoint. This handler does
/// not present any UI.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct AuthAPIPasskeyLoginMethodHandler: MethodHandler {
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
                                         message: "Failed to reconstruct login challenge",
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

    private static func reconstructChallenge(
        from challengeMap: [String: Any]) -> PasskeyLoginChallenge? {
        guard let authParamsPublicKey = challengeMap["authParamsPublicKey"] as? [String: Any],
              let authSession = challengeMap["authSession"] as? String,
              let challengeString = authParamsPublicKey["challenge"] as? String,
              let relyingPartyId = authParamsPublicKey["rpId"] as? String else {
            return nil
        }

        let challengeJson: [String: Any] = [
            "auth_session": authSession,
            "authn_params_public_key": [
                "rpId": relyingPartyId,
                "challenge": challengeString
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: challengeJson) else {
            return nil
        }
        return try? JSONDecoder().decode(PasskeyLoginChallenge.self, from: jsonData)
    }

    private static func reconstructPasskey(
        from credentialMap: [String: Any]) -> LoginPasskey? {
        guard let credentialIdString = credentialMap["rawId"] as? String
                ?? credentialMap["id"] as? String,
              let credentialID = Data.fromBase64URLEncoded(credentialIdString),
              let response = credentialMap["response"] as? [String: Any],
              let clientDataString = response["clientDataJSON"] as? String,
              let rawClientDataJSON = Data.fromBase64URLEncoded(clientDataString),
              let authenticatorDataString = response["authenticatorData"] as? String,
              let rawAuthenticatorData = Data.fromBase64URLEncoded(authenticatorDataString),
              let signatureString = response["signature"] as? String,
              let signature = Data.fromBase64URLEncoded(signatureString) else {
            return nil
        }

        // Auth0.swift force-unwraps `userID` when building the request, so fall
        // back to empty data rather than nil when no user handle was returned.
        let userID = (response["userHandle"] as? String)
            .flatMap { Data.fromBase64URLEncoded($0) } ?? Data()

        let attachment: ASAuthorizationPublicKeyCredentialAttachment =
            (credentialMap["authenticatorAttachment"] as? String) == "crossPlatform"
                ? .crossPlatform : .platform

        return ReconstructedLoginPasskey(
            userID: userID,
            credentialID: credentialID,
            attachment: attachment,
            rawClientDataJSON: rawClientDataJSON,
            rawAuthenticatorData: rawAuthenticatorData,
            signature: signature
        )
    }
}
#endif
