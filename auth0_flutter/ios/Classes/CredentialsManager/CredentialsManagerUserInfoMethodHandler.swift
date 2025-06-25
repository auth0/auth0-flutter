
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerUserInfoMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        callback(credentialsManager.user)
    }
}
