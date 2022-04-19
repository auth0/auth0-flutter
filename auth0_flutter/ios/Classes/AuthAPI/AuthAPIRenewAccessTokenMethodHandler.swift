import Flutter
import Auth0

struct AuthAPIRenewAccessTokenMethodHandler: MethodHandler {
    enum Argument: String {
        case refreshToken
        case scopes
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let refreshToken = arguments[Argument.refreshToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.refreshToken.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .renew(withRefreshToken: refreshToken,
                   scope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
