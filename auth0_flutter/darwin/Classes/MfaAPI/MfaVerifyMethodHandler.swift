import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MfaVerifyMethodHandler: MethodHandler {
    let client: MFAClient

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let mfaToken = arguments["mfaToken"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("mfaToken")))
        }
        guard let grantType = arguments["grantType"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("grantType")))
        }

        let request: Request<Credentials, MFAVerifyError>

        switch grantType {
        case "otp":
            guard let otp = arguments["otp"] as? String else {
                return callback(FlutterError(from: .requiredArgumentMissing("otp")))
            }
            request = client.verify(otp: otp, mfaToken: mfaToken)
        case "oob":
            guard let oobCode = arguments["oobCode"] as? String else {
                return callback(FlutterError(from: .requiredArgumentMissing("oobCode")))
            }
            let bindingCode = arguments["bindingCode"] as? String
            request = client.verify(oobCode: oobCode, bindingCode: bindingCode, mfaToken: mfaToken)
        case "recovery_code":
            guard let recoveryCode = arguments["recoveryCode"] as? String else {
                return callback(FlutterError(from: .requiredArgumentMissing("recoveryCode")))
            }
            request = client.verify(recoveryCode: recoveryCode, mfaToken: mfaToken)
        default:
            return callback(FlutterError(from: .requiredArgumentMissing("grantType")))
        }

        request.start {
            switch $0 {
            case let .success(credentials):
                callback(self.result(from: credentials))
            case let .failure(error):
                callback(FlutterError(from: error))
            }
        }
    }
}
