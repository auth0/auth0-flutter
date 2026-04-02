import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct ApiCredentialsMethodHandler: MethodHandler {

    enum Argument: String {
        case audience
        case scopes
        case minTtl
        case parameters
        case headers
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let audience = arguments[Argument.audience] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.audience.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let minTTL = arguments[Argument.minTtl] as? Int else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.minTtl.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }
        guard let headers = arguments[Argument.headers] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.headers.rawValue)))
        }

        self.credentialsManager.apiCredentials(forAudience: audience,
                                               scope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString,
                                               minTTL: minTTL,
                                               parameters: parameters,
                                               headers: headers) {
            switch $0 {
            case let .success(apiCredentials): callback(apiCredentials.asDictionary())
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }

}
