import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPasswordlessPhoneNumberMethodHandler: MethodHandler {
    enum Argument: String {
        case phoneNumber
        case passwordlessType
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let phoneNumber = arguments[Argument.phoneNumber] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.phoneNumber.rawValue)))
        }

        guard let passwordlessTypeString = arguments[Argument.passwordlessType] as? String,
              let passwordlessType = PasswordlessType(rawValue: passwordlessTypeString) else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.passwordlessType.rawValue)))
        }

        guard let parameters = arguments[Argument.parameters] as? [String: Any] else {
             return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .startPasswordless(phoneNumber: phoneNumber,
                               type: passwordlessType,
                               connection: "sms"
            )
            .parameters(["authParams":parameters])
            .start {
                switch $0 {
                case .success:
                    callback(nil)

                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}

