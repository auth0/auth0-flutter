import Flutter
import Auth0

struct AuthAPIResetPasswordMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case connection
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }
        guard let connection = arguments[Argument.connection] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .resetPassword(email: email, connection: connection)
            .parameters(parameters)
            .start {
                switch $0 {
                case .success: callback(nil)
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
