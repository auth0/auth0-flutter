import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct SSOCredentialsMethodHandler: MethodHandler {

    enum Argument: String {
        case parameters
        case headers
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let parameters = arguments[Argument.parameters] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }
        guard let headers = arguments[Argument.headers] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.headers.rawValue)))
        }

        self.credentialsManager.ssoCredentials(parameters: parameters, headers: headers) {
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
