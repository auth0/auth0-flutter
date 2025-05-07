import Foundation
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif


struct WebAuthCancelMethodHandler: MethodHandler {

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        WebAuthentication.cancel()
    }
}
