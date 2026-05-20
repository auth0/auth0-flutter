import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountGetFactorsMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        client
            .authenticationMethods
            .getFactors()
            .start {
                switch $0 {
                case let .success(factors):
                    callback(factors.map { ["name": $0.type, "enabled": true] })
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
