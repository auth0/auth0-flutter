import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerHasValidMethodHandler: MethodHandler {
    enum Argument: String {
        case minTtl
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let minTTL = arguments[Argument.minTtl] as? Int else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.minTtl.rawValue)))
        }

        // So it behaves the same as the Credentials Manager from Auth0.Android
        callback(self.credentialsManager.canRenew() || self.credentialsManager.hasValid(minTTL: minTTL))
    }
}
