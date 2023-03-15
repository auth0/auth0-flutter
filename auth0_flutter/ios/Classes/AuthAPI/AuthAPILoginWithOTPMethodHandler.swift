import Flutter
import Auth0

struct AuthAPILoginWithOTPMethodHandler: MethodHandler {
    enum Argument: String {
        case otp
        case mfaToken
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let otp = arguments[Argument.otp] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.otp.rawValue)))
        }
        guard let mfaToken = arguments[Argument.mfaToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.mfaToken.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .login(withOTP: otp, mfaToken: mfaToken)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}
