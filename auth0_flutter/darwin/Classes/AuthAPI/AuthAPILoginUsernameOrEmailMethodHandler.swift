import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPILoginUsernameOrEmailMethodHandler: MethodHandler {
    enum Argument: String {
        case usernameOrEmail
        case password
        case connectionOrRealm
        case scopes
        case parameters
        case audience
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let usernameOrEmail = arguments[Argument.usernameOrEmail] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.usernameOrEmail.rawValue)))
        }
        guard let password = arguments[Argument.password] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.password.rawValue)))
        }
        guard let connectionOrRealm = arguments[Argument.connectionOrRealm] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connectionOrRealm.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        let audience = arguments[Argument.audience] as? String

        client
            .login(usernameOrEmail: usernameOrEmail,
                   password: password,
                   realmOrConnection: connectionOrRealm,
                   audience: audience,
                   scope: scopes.asSpaceSeparatedString)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
