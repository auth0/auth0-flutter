import Flutter
import Auth0

fileprivate extension MethodHandler {
    func result(from userInfo: UserInfo) -> Any? {
        return userInfo.asDictionary()
    }
}

struct AuthAPIUserInfoMethodHandler: MethodHandler {
    enum Argument: String {
        case accessToken
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let accessToken = arguments[Argument.accessToken.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.accessToken.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .userInfo(withAccessToken: accessToken)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(userInfo): callback(result(from: userInfo))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
