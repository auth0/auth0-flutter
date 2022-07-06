import Flutter
import Auth0

struct CredentialsManagerClearMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        callback(credentialsManager.clear())
    }
}
