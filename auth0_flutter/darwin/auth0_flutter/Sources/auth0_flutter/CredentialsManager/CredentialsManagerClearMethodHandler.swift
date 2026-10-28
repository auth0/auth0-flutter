import Auth0
import SimpleKeychain

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct CredentialsManagerClearMethodHandler: MethodHandler {
    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        do {
            try self.credentialsManager.clear()
            callback(true)
        } catch let error as SimpleKeychainError where error == .itemNotFound {
            callback(false)
        } catch {
            callback(FlutterError(from: (error as? CredentialsManagerError) ?? .unknown))
        }
    }
}
