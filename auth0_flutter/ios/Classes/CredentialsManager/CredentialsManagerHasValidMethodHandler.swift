import Flutter
import Auth0

struct CredentialsManagerHasValidMethodHandler: MethodHandler {
    enum Argument: String {
        case minTtl
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let minTTL = arguments[Argument.minTtl] as? Int else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.minTtl.rawValue)))
        }

        callback(credentialsManager.hasValid(minTTL: minTTL))
    }
}
