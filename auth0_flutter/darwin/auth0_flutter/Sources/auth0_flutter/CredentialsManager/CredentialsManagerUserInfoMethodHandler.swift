
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerUserInfoMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        if let user = try? credentialsManager.userProfile() {
            callback(user.asDictionary())
        } else {
            callback(nil)
        }
    }
}
