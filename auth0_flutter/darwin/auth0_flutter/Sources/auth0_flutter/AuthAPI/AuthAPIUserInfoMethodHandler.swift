import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

fileprivate extension MethodHandler {
    func result(from userInfo: UserInfo) -> Any? {
        return userInfo.asDictionary()
    }
}

struct AuthAPIUserInfoMethodHandler: MethodHandler {
    enum Argument: String {
        case accessToken
        case parameters
        case tokenType
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let accessToken = arguments[Argument.accessToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.accessToken.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }
        
        let tokenType = arguments[Argument.tokenType] as? String ?? "Bearer"

        client
            .userInfo(withAccessToken: accessToken, tokenType: tokenType)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(userInfo): callback(result(from: userInfo))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
