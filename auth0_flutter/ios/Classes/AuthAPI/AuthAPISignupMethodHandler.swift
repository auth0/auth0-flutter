import Flutter
import Auth0

enum DatabaseUserProperty: String {
    case email
    case emailVerified
    case username
}

fileprivate extension MethodHandler {
    func result(from databaseUser: DatabaseUser) -> Any? {
        var data: [String: Any] = [
            DatabaseUserProperty.email.rawValue: databaseUser.email,
            DatabaseUserProperty.emailVerified.rawValue: databaseUser.verified
        ]
        data[DatabaseUserProperty.username] = databaseUser.username
        return data
    }
}

struct AuthAPISignupMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case password
        case connection
        case username
        case userMetadata
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }
        guard let password = arguments[Argument.password] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.password.rawValue)))
        }
        guard let connection = arguments[Argument.connection] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }
        guard let userMetadata = arguments[Argument.userMetadata] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.userMetadata.rawValue)))
        }

        let username = arguments[Argument.username] as? String

        client
            .signup(email: email,
                    username: username,
                    password: password,
                    connection: connection,
                    userMetadata: userMetadata)
            .start {
                switch $0 {
                case let .success(databaseUser): callback(result(from: databaseUser))
                case let .failure(error): callback(FlutterError(from: error))
                }

            }
    }
}
