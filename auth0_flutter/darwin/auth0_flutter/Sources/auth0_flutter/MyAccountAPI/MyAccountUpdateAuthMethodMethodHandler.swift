import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountUpdateAuthMethodMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let id = arguments["id"] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing("id")))
        }

        let name = arguments["name"] as? String
        let preferredAuthenticationMethod =
            (arguments["preferredAuthenticationMethod"] as? String)
                .flatMap(PreferredAuthenticationMethod.init(rawValue:))

        client
            .authenticationMethods
            .updateAuthenticationMethod(by: id,
                                        name: name,
                                        preferredAuthenticationMethod: preferredAuthenticationMethod)
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
