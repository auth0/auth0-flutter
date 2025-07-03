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
    }

    let credentialsManager: CredentialsManager

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
        
        let forceRenew = (arguments[Argument.forceRefresh] as? Bool) ?? false

        self.credentialsManager.retrieveCredentials(withScope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString,
                                       minTTL: minTTL,
                                      parameters: parameters,headers: [:],
                                      forceRenewal: forceRenew) {
            switch $0 {
            case let .success(credentials): callback(result(from: credentials))
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
