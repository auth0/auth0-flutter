import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerSaveMethodHandler: MethodHandler {
    enum Argument: String {
        case credentials
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let credentialsDictionary = arguments[Argument.credentials] as? [String: Any],
              let credentials = Credentials(from: credentialsDictionary) else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.credentials.rawValue)))
        }

        callback(self.credentialsManager.store(credentials: credentials))
    }
}
