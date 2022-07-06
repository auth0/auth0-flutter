import Flutter
import Auth0

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

        callback(credentialsManager.store(credentials: credentials))
    }
}
