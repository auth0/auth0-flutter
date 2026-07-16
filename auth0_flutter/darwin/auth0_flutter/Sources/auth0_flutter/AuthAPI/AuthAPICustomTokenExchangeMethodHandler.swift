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
        case actorToken
        case actorTokenType
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let subjectToken = arguments[Argument.subjectToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectToken.rawValue)))
        }
        guard let subjectTokenType = arguments[Argument.subjectTokenType] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.subjectTokenType.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String], !scopes.isEmpty else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        
        let scope = scopes.asSpaceSeparatedString
        let audience = arguments[Argument.audience] as? String
        let organization = arguments[Argument.organization] as? String

        var actorToken: ActorToken?
        if let actorTokenValue = arguments[Argument.actorToken] as? String,
           let actorTokenType = arguments[Argument.actorTokenType] as? String {
            actorToken = ActorToken(token: actorTokenValue, tokenType: actorTokenType)
        }

        client
            .customTokenExchange(subjectToken: subjectToken,
                               subjectTokenType: subjectTokenType,
                               audience: audience,
                               scope: scope,
                               organization: organization,
                               actorToken: actorToken)
            .start {
                switch $0 {
                case .success(let credentials): callback(self.result(from: credentials))
                case .failure(let error): callback(FlutterError(from: error))
                }
            }
    }
}