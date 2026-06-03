#if PASSKEYS_PLATFORM
import Auth0
import AuthenticationServices

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// Presents the operating system's passkey UI for an existing login challenge
/// and returns the resulting assertion as a WebAuthn credential. This handler
/// does not contact Auth0; the returned credential is passed back to
/// ``AuthAPIPasskeyLoginMethodHandler`` to exchange for tokens.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeyCreateCredentialMethodHandler: NSObject, MethodHandler,
    ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    enum Argument: String {
        case challenge
    }

    private var pendingCallback: FlutterResult?
    private var controller: ASAuthorizationController?
    // `ASAuthorizationController` holds its delegate weakly, so retain this
    // handler until the authorization completes — otherwise it is deallocated
    // when `handle(with:)` returns and the delegate callbacks never fire.
    private var selfRetain: AuthAPIPasskeyCreateCredentialMethodHandler?

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let challengeMap = arguments[Argument.challenge.rawValue] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.challenge.rawValue)))
        }
        guard let authParamsPublicKey = challengeMap["authParamsPublicKey"] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing("challenge.authParamsPublicKey")))
        }
        guard let challengeString = authParamsPublicKey["challenge"] as? String,
              let challengeData = Data.fromBase64URLEncoded(challengeString) else {
            return callback(FlutterError(from: .requiredArgumentMissing("challenge.authParamsPublicKey.challenge")))
        }
        guard let relyingPartyId = authParamsPublicKey["rpId"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("challenge.authParamsPublicKey.rpId")))
        }

        self.pendingCallback = callback
        self.selfRetain = self

        #if DEBUG
        NSLog("[Auth0Passkey] createCredential: presenting UI for rpId=\(relyingPartyId)")
        #endif

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: relyingPartyId
        )
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.controller = controller

        // The passkey UI must be presented from the main thread.
        if Thread.isMainThread {
            controller.performRequests()
        } else {
            DispatchQueue.main.async { controller.performRequests() }
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        #if DEBUG
        NSLog("[Auth0Passkey] createCredential: didCompleteWithAuthorization")
        #endif
        guard let callback = pendingCallback else { return }

        guard let credential = authorization.credential
                as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
            callback(FlutterError(code: "PASSKEY_ERROR",
                                  message: "Unexpected credential type",
                                  details: nil))
            cleanup()
            return
        }

        // `authenticatorData` and `signature` are mandatory for a valid WebAuthn
        // assertion. Fail fast with a clear client error rather than forwarding
        // empty data, which would only surface as an opaque /oauth/token reject.
        guard let rawAuthenticatorData = credential.rawAuthenticatorData else {
            callback(FlutterError(code: "PASSKEY_ERROR",
                                  message: "Passkey assertion is missing authenticator data",
                                  details: nil))
            cleanup()
            return
        }
        guard let signature = credential.signature else {
            callback(FlutterError(code: "PASSKEY_ERROR",
                                  message: "Passkey assertion is missing signature",
                                  details: nil))
            cleanup()
            return
        }

        var response: [String: Any] = [
            "clientDataJSON": credential.rawClientDataJSON.base64URLEncodedString(),
            "authenticatorData": rawAuthenticatorData.base64URLEncodedString(),
            "signature": signature.base64URLEncodedString()
        ]
        if let userID = credential.userID {
            response["userHandle"] = userID.base64URLEncodedString()
        }

        let credentialId = credential.credentialID.base64URLEncodedString()
        let result: [String: Any] = [
            "id": credentialId,
            "rawId": credentialId,
            "type": "public-key",
            "authenticatorAttachment": "platform",
            "response": response
        ]

        callback(result)
        cleanup()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        #if DEBUG
        NSLog("[Auth0Passkey] createCredential: didCompleteWithError \(error.localizedDescription)")
        #endif
        guard let callback = pendingCallback else { return }
        let authError = error as? ASAuthorizationError
        let code = authError?.code == .canceled ? "a0.sdk.cancel" : "PASSKEY_ERROR"
        callback(FlutterError(code: code,
                              message: error.localizedDescription,
                              details: nil))
        cleanup()
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let windows = windowScenes.flatMap { $0.windows }
        // Prefer the key window, then any visible window, and only fall back to
        // a detached anchor if the app genuinely has no window — presenting on a
        // detached anchor silently no-ops, so avoid it whenever possible.
        return windows.first(where: \.isKeyWindow)
            ?? windows.first { !$0.isHidden }
            ?? windows.first
            ?? ASPresentationAnchor()
        #else
        return NSApplication.shared.keyWindow
            ?? NSApplication.shared.windows.first
            ?? ASPresentationAnchor()
        #endif
    }

    // MARK: - Private

    private func cleanup() {
        pendingCallback = nil
        controller = nil
        selfRetain = nil
    }
}
#endif
