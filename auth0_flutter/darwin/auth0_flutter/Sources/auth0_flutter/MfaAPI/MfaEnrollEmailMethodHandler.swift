import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MfaEnrollEmailMethodHandler: MethodHandler {
    let client: MFAClient

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let mfaToken = arguments["mfaToken"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("mfaToken")))
        }
        guard let email = arguments["email"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("email")))
        }

        client
            .enroll(mfaToken: mfaToken, email: email)
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
