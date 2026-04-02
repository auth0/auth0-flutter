import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPasswordlessChallengeEmailMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case connection
        case allowSignup
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }
        guard let connection = arguments[Argument.connection] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }

        let allowSignup = arguments[Argument.allowSignup] as? Bool ?? false

        client
            .passwordlessChallenge(email: email,
                                   connection: connection,
                                   allowSignup: allowSignup)
            .start {
                switch $0 {
                case let .success(challenge):
                    callback(["authSession": challenge.authSession])
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
