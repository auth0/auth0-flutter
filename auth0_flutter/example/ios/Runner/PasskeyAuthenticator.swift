import AuthenticationServices
import Flutter
import UIKit

/// Presents the OS passkey UI and returns a WebAuthn credential to Flutter.
///
/// This lives in the example app — not the `auth0_flutter` SDK — to demonstrate
/// how an app supplies the passkey credential that the SDK expects:
/// - `getAssertion` authenticates an existing passkey using the `challenge` and
///   `rpId` from `Auth0.api.passkeyLoginChallenge` (for `Auth0.api.passkeyLogin`).
/// - `getAttestation` registers a new passkey using the `authParamsPublicKey`
///   from `Auth0.api.passkeySignupChallenge` (for `Auth0.api.passkeySignup`).
@available(iOS 16.6, *)
class PasskeyAuthenticator: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    static let channelName = "com.auth0.auth0_flutter_example/passkey"

    private var pendingResult: FlutterResult?
    private var controller: ASAuthorizationController?
    // ASAuthorizationController holds its delegate weakly; retain self until the
    // OS callback fires so it isn't deallocated mid-flow.
    private var selfRetain: PasskeyAuthenticator?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName, binaryMessenger: registrar.messenger())
        let instance = PasskeyAuthenticator()
        channel.setMethodCallHandler { call, result in
            instance.handle(call, result: result)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAssertion":
            handleAssertion(call, result: result)
        case "getAttestation":
            handleAttestation(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Login (assertion)

    private func handleAssertion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let challengeString = args["challenge"] as? String,
              let challengeData = Self.decodeBase64URL(challengeString),
              let rpId = args["rpId"] as? String else {
            return result(FlutterError(code: "bad_args",
                                       message: "Missing challenge or rpId",
                                       details: nil))
        }

        pendingResult = result
        selfRetain = self

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: rpId)
        let request = provider.createCredentialAssertionRequest(
            challenge: challengeData)

        performRequest(request)
    }

    // MARK: - Signup (attestation)

    private func handleAttestation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let publicKey = args["authParamsPublicKey"] as? [String: Any],
              let challengeString = publicKey["challenge"] as? String,
              let challengeData = Self.decodeBase64URL(challengeString),
              let rpId = publicKey["rpId"] as? String,
              let userIdString = publicKey["userId"] as? String,
              let userId = Self.decodeBase64URL(userIdString),
              let userName = publicKey["userName"] as? String else {
            return result(FlutterError(code: "bad_args",
                                       message: "Missing or malformed authParamsPublicKey",
                                       details: nil))
        }

        pendingResult = result
        selfRetain = self

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: rpId)
        let request = provider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: userName,
            userID: userId)

        performRequest(request)
    }

    private func performRequest(_ request: ASAuthorizationRequest) {
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.controller = controller
        if Thread.isMainThread {
            controller.performRequests()
        } else {
            DispatchQueue.main.async { controller.performRequests() }
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let result = pendingResult else { return }

        if let credential = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // Login assertion.
            var response: [String: Any] = [
                "clientDataJSON": Self.encodeBase64URL(credential.rawClientDataJSON),
                "authenticatorData":
                    Self.encodeBase64URL(credential.rawAuthenticatorData ?? Data()),
                "signature": Self.encodeBase64URL(credential.signature ?? Data())
            ]
            if let userID = credential.userID {
                response["userHandle"] = Self.encodeBase64URL(userID)
            }
            let credentialId = Self.encodeBase64URL(credential.credentialID)
            result([
                "id": credentialId,
                "rawId": credentialId,
                "type": "public-key",
                "authenticatorAttachment": "platform",
                "response": response
            ])
            cleanup()
            return
        }

        if let credential = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // Signup attestation.
            let response: [String: Any] = [
                "clientDataJSON": Self.encodeBase64URL(credential.rawClientDataJSON),
                "attestationObject":
                    Self.encodeBase64URL(credential.rawAttestationObject ?? Data())
            ]
            let credentialId = Self.encodeBase64URL(credential.credentialID)
            result([
                "id": credentialId,
                "rawId": credentialId,
                "type": "public-key",
                "authenticatorAttachment": "platform",
                "response": response
            ])
            cleanup()
            return
        }

        result(FlutterError(code: "unexpected_credential",
                            message: "Unexpected credential type",
                            details: nil))
        cleanup()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error) {
        guard let result = pendingResult else { return }
        let authError = error as? ASAuthorizationError
        let code = authError?.code == .canceled ? "canceled" : "passkey_error"
        result(FlutterError(code: code,
                            message: error.localizedDescription,
                            details: nil))
        cleanup()
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(
        for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        return windows.first(where: \.isKeyWindow)
            ?? windows.first
            ?? ASPresentationAnchor()
    }

    // MARK: - Private

    private func cleanup() {
        pendingResult = nil
        controller = nil
        selfRetain = nil
    }

    private static func encodeBase64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }

    private static func decodeBase64URL(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = (4 - base64.count % 4) % 4
        base64 += String(repeating: "=", count: padding)
        return Data(base64Encoded: base64)
    }
}
