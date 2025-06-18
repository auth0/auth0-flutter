import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerGetMethodHandler: MethodHandler {
    enum Argument: String {
        case scopes
        case minTtl
        case parameters
        case forceRefresh
        case headers
    }

        let credentialsManager: CredentialsManagerProtocol

        init(credentialsManager: CredentialsManagerProtocol) {
            self.credentialsManager = credentialsManager
        }

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let minTTL = arguments[Argument.minTtl] as? Int else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.minTtl.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }
        let headers = arguments[Argument.headers] as? [String: String] ?? [:]
        let forceRefresh = arguments[Argument.forceRefresh] as? Bool ?? false

        if forceRefresh {
            self.credentialsManager.renew(parameters: parameters, headers: headers) {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
        } else {
            self.credentialsManager.credentials(withScope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString,
                                           minTTL: minTTL,
                                           parameters: parameters,
                                           headers: headers
            ) {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
        }
    }
}
