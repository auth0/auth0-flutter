import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountEnrollEmailMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments["email"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("email")))
        }

        client
            .authenticationMethods
            .enrollEmail(emailAddress: email)
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
