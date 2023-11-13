import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

protocol MethodHandler {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
}

extension MethodHandler {
    func result(from credentials: Credentials) -> Any? {
        do {
            return try credentials.asDictionary()
        } catch {
            return FlutterError(from: .idTokenDecodingFailed)
        }
    }
}
