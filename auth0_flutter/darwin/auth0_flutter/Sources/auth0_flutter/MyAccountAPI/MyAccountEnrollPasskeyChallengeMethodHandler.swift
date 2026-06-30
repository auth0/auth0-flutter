#if PASSKEYS_PLATFORM
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

/// Requests a passkey enrollment challenge from the My Account API. This is the
/// first part of the enrollment flow; the app then presents the OS passkey
/// creation UI and finishes with `myAccount#enrollPasskey`.
@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
struct MyAccountEnrollPasskeyChallengeMethodHandler: MethodHandler {
    enum Argument: String {
        case userIdentityId
        case connection
    }

    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        let userIdentityId = arguments[Argument.userIdentityId.rawValue] as? String
        let connection = arguments[Argument.connection.rawValue] as? String

        client
            .authenticationMethods
            .passkeyEnrollmentChallenge(userIdentityId: userIdentityId, connection: connection)
            .start {
                switch $0 {
                case let .success(challenge):
                    callback(challenge.asDictionary())
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
#endif
