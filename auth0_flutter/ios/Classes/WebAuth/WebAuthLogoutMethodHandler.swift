import Foundation
import Flutter
import Auth0

struct WebAuthLogoutMethodHandler: MethodHandler {
    enum Argument: String {
        case returnTo
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        var webAuth = client

        if let returnTo = arguments[Argument.returnTo] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

        webAuth.clearSession {
            switch $0 {
            case .success: callback(nil)
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
