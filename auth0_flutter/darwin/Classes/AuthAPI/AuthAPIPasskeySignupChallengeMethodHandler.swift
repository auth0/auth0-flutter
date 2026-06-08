#if PASSKEYS_PLATFORM
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct AuthAPIPasskeySignupChallengeMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case phoneNumber
        case username
        case name
        case givenName
        case familyName
        case nickname
        case picture
        case connection
        case organization
        case userMetadata
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        let email = arguments[Argument.email] as? String
        let phoneNumber = arguments[Argument.phoneNumber] as? String
        let username = arguments[Argument.username] as? String
        let name = arguments[Argument.name] as? String
        let givenName = arguments[Argument.givenName] as? String
        let familyName = arguments[Argument.familyName] as? String
        let nickname = arguments[Argument.nickname] as? String
        let picture = arguments[Argument.picture] as? String
        let connection = arguments[Argument.connection] as? String
        let organization = arguments[Argument.organization] as? String
        let userMetadata = arguments[Argument.userMetadata] as? [String: String]

        client
            .passkeySignupChallenge(email: email,
                                    phoneNumber: phoneNumber,
                                    username: username,
                                    name: name,
                                    givenName: givenName,
                                    familyName: familyName,
                                    nickname: nickname,
                                    picture: picture,
                                    userMetadata: userMetadata,
                                    connection: connection,
                                    organization: organization)
            .start {
                switch $0 {
                case let .success(challenge):
                    let response: [String: Any] = [
                        "authSession": challenge.authenticationSession,
                        "authParamsPublicKey": [
                            "challenge": challenge.challengeData.base64URLEncodedString(),
                            "rpId": challenge.relyingPartyId,
                            "userId": challenge.userId.base64URLEncodedString(),
                            "userName": challenge.userName
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
