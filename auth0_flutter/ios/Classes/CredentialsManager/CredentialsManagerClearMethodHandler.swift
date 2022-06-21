import Foundation
import Flutter
import Auth0

struct CredentialsManagerClearMethodHandler: MethodHandler {

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        callback(nil)
    }
}
