#if MY_ACCOUNT_PROFILE
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountGetUserProfileMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        let fields = arguments["fields"] as? [String]
        let includeFields = arguments["includeFields"] as? Bool ?? true
        let options = GetUserProfileOptions(fields: fields, includeFields: includeFields)

        client
            .authenticationMethods
            .getUserProfile(options: options)
            .start {
                switch $0 {
                case let .success(profile):
                    callback(profile.asDictionary())
                case let .failure(error):
                    callback(FlutterError(from: error))
                }
            }
    }
}
#endif
