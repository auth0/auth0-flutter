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

        client
            .startPasswordless(phoneNumber: phoneNumber,
                               type: passwordlessType,
                               connection: "sms"
            )
            .start {
                switch $0 {
                case let .success:
                    callback(nil)

                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}

