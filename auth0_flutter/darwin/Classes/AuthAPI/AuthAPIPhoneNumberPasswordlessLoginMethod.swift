import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPhoneNumberPasswordlessLoginMethod: MethodHandler {
    enum Argument: String {
        case phoneNumber
        case passwordlessType
        case connection
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

        let connection = arguments[Argument.connection] as? String ?? "sms"

        client
            .startPasswordless(email: email,
                               type: passwordlessType,
                               connection: connection
            )
            .start {
                switch $0 {
                case let .success:
                    print("Passwordless sms sent")
                    callback(result(nil))

                case let .failure(error):
                    print("Passwordless sms failed error")
                    callback(FlutterError(from: error))
                }
            }
    }
}

