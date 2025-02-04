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
        case scopes
        case audience
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let phoneNumber = arguments[Argument.phoneNumber] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.phoneNumber.rawValue)))
        }

        guard let verificationCode = arguments[Argument.verificationCode] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.verificationCode.rawValue)))
        }

        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }

        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
              return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }


        let audience = arguments[Argument.audience] as? String

        client
            .login(phoneNumber: phoneNumber,
                   code: verificationCode,
                   audience: audience,
                   scope: scopes.asSpaceSeparatedString
            )
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error):callback(FlutterError(from: error))
                }
            }
    }
}

