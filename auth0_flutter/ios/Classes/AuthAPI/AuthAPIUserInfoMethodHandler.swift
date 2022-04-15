import Flutter
import Auth0

extension MethodHandler {
    func result(from userInfo: UserInfo) -> Any? {
        return userInfo.asDictionary()
    }
}

struct AuthAPIUserInfoMethodHandler: MethodHandler {
    enum Argument: String {
        case accessToken
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let accessToken = arguments[Argument.accessToken.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.accessToken.rawValue)))
        }

        client
            .userInfo(withAccessToken: accessToken)
            .start {
                switch $0 {
                case let .success(userInfo): callback(result(from: userInfo))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
