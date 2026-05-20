import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountGetAuthMethodsMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        client
            .authenticationMethods
            .getAuthenticationMethods()
            .start {
                switch $0 {
                case let .success(methods):
                    callback(methods.map { $0.asDictionary() })
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
