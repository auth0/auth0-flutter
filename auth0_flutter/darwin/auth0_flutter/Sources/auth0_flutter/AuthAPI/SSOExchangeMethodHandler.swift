import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct SSOExchangeMethodHandler: MethodHandler {
    enum Argument: String {
        case refreshToken
        case parameters
        case headers
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let refreshToken = arguments[Argument.refreshToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.refreshToken.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }
        guard let headers = arguments[Argument.headers] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.headers.rawValue)))
        }

        client
            .ssoExchange(withRefreshToken: refreshToken)
            .parameters(parameters)
            .headers(headers)
            .start {
                switch $0 {
                case let .success(ssoCredentials):
                    var response: [String: Any] = [
                        "sessionTransferToken": ssoCredentials.sessionTransferToken,
                        "tokenType": ssoCredentials.issuedTokenType,
                        "expiresIn": Int(ssoCredentials.expiresIn.timeIntervalSinceNow)
                    ]
                    response["idToken"] = ssoCredentials.idToken
                    if let refreshToken = ssoCredentials.refreshToken {
                        response["refreshToken"] = refreshToken
                    }
                    callback(response)
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
