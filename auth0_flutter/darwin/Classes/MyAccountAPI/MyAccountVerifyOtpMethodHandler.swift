import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountVerifyOtpMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let id = arguments["id"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("id")))
        }
        guard let authSession = arguments["authSession"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("authSession")))
        }
        guard let otp = arguments["otp"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("otp")))
        }

        client
            .authenticationMethods
            .confirmPhoneEnrollment(id: id, authSession: authSession, otpCode: otp)
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
