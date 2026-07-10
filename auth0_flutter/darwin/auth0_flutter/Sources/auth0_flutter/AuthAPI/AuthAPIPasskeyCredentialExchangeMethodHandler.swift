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

/// A ``SignupPasskey`` reconstructed from a credential map supplied by the app
/// (for example, from `ASAuthorizationController`).
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
private struct ReconstructedSignupPasskey: SignupPasskey {
    let credentialID: Data
    let attachment: ASAuthorizationPublicKeyCredentialAttachment
    let rawClientDataJSON: Data
    let rawAttestationObject: Data?
}

/// Exchanges an app-supplied passkey credential (a login assertion or a signup
/// attestation) and its challenge for Auth0 tokens at the `/oauth/token`
/// endpoint. This handler does not present any UI.
///
/// Both passkey login and signup finish here. The credential's `response`
/// determines the flow: an `attestationObject` indicates a signup attestation,
/// while `authenticatorData` + `signature` indicate a login assertion. The
/// matching `LoginPasskey`/`SignupPasskey` and challenge are reconstructed and
/// passed to the shared `Authentication.login(passkey:challenge:...)` call.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct AuthAPIPasskeyCredentialExchangeMethodHandler: MethodHandler {
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

        let connection = arguments[Argument.connection.rawValue] as? String
        let audience = arguments[Argument.audience.rawValue] as? String
        let scopes = (arguments[Argument.scopes.rawValue] as? [String]) ?? []
        let organization = arguments[Argument.organization.rawValue] as? String
        let parameters = (arguments[Argument.parameters.rawValue] as? [String: Any]) ?? [:]

        let response = credentialMap["response"] as? [String: Any]
        let isSignup = response?["attestationObject"] != nil

        let request: Request<Credentials, AuthenticationError>
        if isSignup {
            guard let challenge = Self.reconstructSignupChallenge(from: challengeMap) else {
                return callback(FlutterError(code: "PASSKEY_ERROR",
                                             message: "Failed to reconstruct signup challenge",
                                             details: nil))
            }
            guard let passkey = Self.reconstructSignupPasskey(from: credentialMap) else {
                return callback(FlutterError(code: "PASSKEY_ERROR",
                                             message: "Failed to reconstruct passkey credential",
                                             details: nil))
            }
            request = client.login(passkey: passkey,
                                   challenge: challenge,
                                   connection: connection,
                                   audience: audience,
                                   scope: scopes.asSpaceSeparatedString,
                                   organization: organization)
        } else {
            guard let challenge = Self.reconstructLoginChallenge(from: challengeMap) else {
                return callback(FlutterError(code: "PASSKEY_ERROR",
                                             message: "Failed to reconstruct login challenge",
                                             details: nil))
            }
            guard let passkey = Self.reconstructLoginPasskey(from: credentialMap) else {
                return callback(FlutterError(code: "PASSKEY_ERROR",
                                             message: "Failed to reconstruct passkey credential",
                                             details: nil))
            }
            request = client.login(passkey: passkey,
                                   challenge: challenge,
                                   connection: connection,
                                   audience: audience,
                                   scope: scopes.asSpaceSeparatedString,
                                   organization: organization)
        }

        request
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

    // MARK: - Login reconstruction

    private static func reconstructLoginChallenge(
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

    private static func reconstructLoginPasskey(
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

    // MARK: - Signup reconstruction

    private static func reconstructSignupChallenge(
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

    private static func reconstructSignupPasskey(
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
