
import Auth0
import SimpleKeychain

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerUserInfoMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        do {
            let user = try credentialsManager.userProfile()
            callback(user?.asDictionary())
        } catch let error as CredentialsManagerError where (error.cause as? SimpleKeychainError) == .itemNotFound {
            callback(nil)
        } catch {
            callback(FlutterError(from: (error as? CredentialsManagerError) ?? .unknown))
        }
    }
}
