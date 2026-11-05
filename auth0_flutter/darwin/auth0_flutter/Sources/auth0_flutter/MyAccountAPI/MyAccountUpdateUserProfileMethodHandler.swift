#if MY_ACCOUNT_PROFILE
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct MyAccountUpdateUserProfileMethodHandler: MethodHandler {
    let client: MyAccount

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        let request = UpdateUserProfileRequest(givenName: arguments["givenName"] as? String,
                                               familyName: arguments["familyName"] as? String,
                                               name: arguments["name"] as? String,
                                               nickname: arguments["nickname"] as? String,
                                               picture: arguments["picture"] as? String)

        client
            .authenticationMethods
            .updateUserProfile(request)
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
