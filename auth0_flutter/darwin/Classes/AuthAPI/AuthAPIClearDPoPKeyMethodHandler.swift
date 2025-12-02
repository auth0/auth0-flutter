import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIClearDPoPKeyMethodHandler: MethodHandler {
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        // Clear the DPoP key pair from the keychain using the static DPoP.clearKeypair method
        do {
            try DPoP.clearKeypair()
            callback(nil)
        } catch {
            callback(FlutterError(code: "CLEAR_DPOP_KEY_ERROR",
                                message: error.localizedDescription,
                                details: nil))
        }
    }
}
