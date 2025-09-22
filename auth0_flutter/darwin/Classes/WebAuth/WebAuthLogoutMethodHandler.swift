import Foundation
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct WebAuthLogoutMethodHandler: MethodHandler {
    enum Argument: String {
        case useHTTPS
        case returnTo
        case federated // Add this
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let useHTTPS = arguments[Argument.useHTTPS] as? Bool else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.useHTTPS.rawValue)))
        }

        // Extract federated parameter, default to false if not provided
        let federated = arguments[Argument.federated.rawValue] as? Bool ?? false

        var webAuth = client

        if useHTTPS {
            webAuth = webAuth.useHTTPS()
        }

        if let returnTo = arguments[Argument.returnTo] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

        webAuth.clearSession(federated: federated) { // Pass federated here
            switch $0 {
            case .success: callback(nil)
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
