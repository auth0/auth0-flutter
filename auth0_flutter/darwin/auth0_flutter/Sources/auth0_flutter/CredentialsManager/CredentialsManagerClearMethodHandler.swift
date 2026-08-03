import Auth0

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
        } catch {
            callback(FlutterError(from: (error as? CredentialsManagerError) ?? .unknown))
        }
    }
}
