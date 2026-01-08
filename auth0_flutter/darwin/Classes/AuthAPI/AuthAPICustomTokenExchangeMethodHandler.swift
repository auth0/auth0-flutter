import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPICustomTokenExchangeMethodHandler: MethodHandler {
    enum Argument: String {
        case subjectToken
        case subjectTokenType
        case audience
        case scopes
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let subjectToken = arguments[Argument.subjectToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectToken.rawValue)))
        }
        guard let subjectTokenType = arguments[Argument.subjectTokenType] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectTokenType.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        let audience = arguments[Argument.audience] as? String

        client
            .customTokenExchange(subjectToken: subjectToken,
                               subjectTokenType: subjectTokenType,
                               audience: audience)
            .parameters(parameters)
            .start {
                switch $0 {
                case .success(let credentials): callback(self.result(from: credentials))
                case .failure(let error): callback(FlutterError(from: error))
                }
            }
    }
}
