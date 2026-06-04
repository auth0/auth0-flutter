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

        guard let factorType = arguments["factorType"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("factorType")))
        }

        let request: any Request<AuthenticationMethod, MyAccountError>
        switch factorType {
        case "email":
            request = client.authenticationMethods.confirmEmailEnrollment(id: id, authSession: authSession, otpCode: otp)
        case "totp":
            request = client.authenticationMethods.confirmTOTPEnrollment(id: id, authSession: authSession, otpCode: otp)
        default:
            request = client.authenticationMethods.confirmPhoneEnrollment(id: id, authSession: authSession, otpCode: otp)
        }

        request.start {
            switch $0 {
            case let .success(method):
                callback(method.asDictionary())
            case let .failure(error):
                callback(FlutterError(from: error))
            }
        }
    }
}
