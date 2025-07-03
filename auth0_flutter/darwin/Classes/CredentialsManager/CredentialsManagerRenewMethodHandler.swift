import Auth0
import SimpleKeychain


#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerRenewMethodHandler: MethodHandler {
    
    enum Argument: String {
        case parameters
    }
    
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {

        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        self.credentialsManager.renew(parameters: parameters) {
            switch $0 {
            case let .success(credentials): callback(result(from: credentials))
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
    
}
