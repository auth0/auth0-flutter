import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPILoginWithPhoneNumberMethodHandler: MethodHandler {
    enum Argument: String {
        case phoneNumber
        case verificationCode
        case scope
        case audience
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let phoneNumber = arguments[Argument.phoneNumber] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }

        guard let verificationCode = arguments[Argument.verificationCode] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.verificationCode.rawValue)))
        }

        guard let scope = arguments[Argument.scope] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scope.rawValue)))
        }

        let audience = arguments[Argument.audience] as? String

        client
            .login(phoneNumber: phoneNumber,
                   code: verificationCode,
                   scope: scope,
                   audience: audience
            )
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error):callback(FlutterError(from: error))
                }
            }
    }
}

