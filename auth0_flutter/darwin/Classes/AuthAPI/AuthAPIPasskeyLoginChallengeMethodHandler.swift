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
