
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerUserInfoMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        if let user = credentialsManager.user {
            callback(user.asDictionary())
        } else {
            callback(nil)
        }
    }
}
