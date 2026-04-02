#if PASSKEYS_PLATFORM
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct AuthAPIPasskeyLoginChallengeMethodHandler: MethodHandler {
    enum Argument: String {
        case connection
        case organization
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        let connection = arguments[Argument.connection] as? String
        let organization = arguments[Argument.organization] as? String

        client
            .passkeyLoginChallenge(connection: connection, organization: organization)
            .start {
                switch $0 {
                case let .success(challenge):
                    // Unlike Android, the iOS Auth0.swift challenge only exposes
                    // the relying-party id and challenge data; `timeout` and
                    // `userVerification` are not surfaced by the native API and
                    // are not needed to build the assertion request here. The
                    // asymmetry with the Android payload is intentional.
                    let response: [String: Any] = [
                        "authSession": challenge.authenticationSession,
                        "authParamsPublicKey": [
                            "challenge": challenge.challengeData.base64URLEncodedString(),
                            "rpId": challenge.relyingPartyId
                        ]
                    ]
                    callback(response)
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
#endif
