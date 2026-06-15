import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountEnrollPhoneMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let phoneNumber = arguments["phoneNumber"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("phoneNumber")))
        }
        guard let typeString = arguments["type"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("type")))
        }

        let preferredMethod: PreferredAuthenticationMethod = typeString == "voice" ? .voice : .sms

        client
            .authenticationMethods
            .enrollPhone(phoneNumber: phoneNumber, preferredAuthenticationMethod: preferredMethod)
            .start {
                switch $0 {
                case let .success(challenge):
                    callback(challenge.asDictionary())
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
