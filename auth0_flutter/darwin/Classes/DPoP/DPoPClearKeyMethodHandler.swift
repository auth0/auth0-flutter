import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct DPoPClearKeyMethodHandler: MethodHandler {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
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
