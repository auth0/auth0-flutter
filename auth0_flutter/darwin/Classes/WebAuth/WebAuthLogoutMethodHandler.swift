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
<<<<<<< HEAD
        case parameters
=======
        case federated
>>>>>>> main
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let useHTTPS = arguments[Argument.useHTTPS] as? Bool else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.useHTTPS.rawValue)))
        }

        var webAuth = client

        if useHTTPS {
            webAuth = webAuth.useHTTPS()
        }

        if let returnTo = arguments[Argument.returnTo] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

<<<<<<< HEAD
        let parameters = arguments[Argument.parameters] as? [String: Any]
        let federatedLogout = parameters?["federated"] as? Bool ?? false

        webAuth.clearSession(federated: federatedLogout) {
=======
        if let federated = arguments[Argument.federated] as? Bool, federated {
            webAuth = webAuth.federated()
        }

        webAuth.clearSession {
>>>>>>> main
            switch $0 {
            case .success: callback(nil)
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
