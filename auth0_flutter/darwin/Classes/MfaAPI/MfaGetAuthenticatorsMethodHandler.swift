import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MfaGetAuthenticatorsMethodHandler: MethodHandler {
    let client: MFAClient

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let mfaToken = arguments["mfaToken"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("mfaToken")))
        }

        let factorsAllowed = arguments["factorsAllowed"] as? [String] ?? []

        client
            .getAuthenticators(mfaToken: mfaToken,
                               factorsAllowed: factorsAllowed)
            .start {
                switch $0 {
                case let .success(authenticators):
                    callback(authenticators.map { $0.asDictionary() })
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
