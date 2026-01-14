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
        case organization
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let subjectToken = arguments[Argument.subjectToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectToken.rawValue)))
        }
        guard let subjectTokenType = arguments[Argument.subjectTokenType] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectTokenType.rawValue)))
        }
        
        let scopes = arguments[Argument.scopes] as? [String] ?? []
        let scope = scopes.isEmpty ? "openid profile email" : scopes.asSpaceSeparatedString
        let audience = arguments[Argument.audience] as? String
        let organization = arguments[Argument.organization] as? String

        client
            .customTokenExchange(subjectToken: subjectToken,
                               subjectTokenType: subjectTokenType,
                               audience: audience,
                               scope: scope,
                               organization: organization)
            .start {
                switch $0 {
                case .success(let credentials): callback(self.result(from: credentials))
                case .failure(let error): callback(FlutterError(from: error))
                }
            }
    }
}