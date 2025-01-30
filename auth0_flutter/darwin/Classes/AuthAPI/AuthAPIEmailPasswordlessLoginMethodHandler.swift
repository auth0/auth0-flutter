import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPasswordlessEmailMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case passwordlessType
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }

        guard let passwordlessTypeString = arguments[Argument.passwordlessType] as? String,
              let passwordlessType = PasswordlessType(rawValue: passwordlessTypeString) else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.passwordlessType.rawValue)))
        }

        client
            .startPasswordless(email: email,
                               type: passwordlessType,
                               connection: "email"
            )
            .start {
                switch $0 {
                case let .success:
                    callback(nil)
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
