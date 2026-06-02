import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountConfirmEnrollmentMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let id = arguments["id"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("id")))
        }
        guard let authSession = arguments["authSession"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("authSession")))
        }

        client
            .authenticationMethods
            .confirmRecoveryCodeEnrollment(id: id, authSession: authSession)
            .start {
                switch $0 {
                case let .success(method):
                    callback(method.asDictionary())
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
