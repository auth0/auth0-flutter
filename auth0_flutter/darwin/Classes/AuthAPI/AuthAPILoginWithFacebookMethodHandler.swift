import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPILoginWithFacebookMethodHandler: MethodHandler {
    enum Argument: String {
        case accessToken
        case scopes
        case parameters
        case audience
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let accessToken = arguments[Argument.accessToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.accessToken.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        let audience = arguments[Argument.audience] as? String

        client
            .login(facebookSessionAccessToken: accessToken,
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
