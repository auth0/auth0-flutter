import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPasswordlessChallengePhoneNumberMethodHandler: MethodHandler {
    enum Argument: String {
        case phoneNumber
        case connection
        case deliveryMethod
        case allowSignup
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let phoneNumber = arguments[Argument.phoneNumber] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.phoneNumber.rawValue)))
        }
        guard let connection = arguments[Argument.connection] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }

        let allowSignup = arguments[Argument.allowSignup] as? Bool ?? false
        let deliveryMethodString = arguments[Argument.deliveryMethod] as? String
        let deliveryMethod = DeliveryMethod(rawValue: deliveryMethodString ?? "") ?? .text

        client
            .passwordlessChallenge(phoneNumber: phoneNumber,
                                   connection: connection,
                                   deliveryMethod: deliveryMethod,
                                   allowSignup: allowSignup)
            .start {
                switch $0 {
                case let .success(challenge):
                    callback(["authSession": challenge.authSession])
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
