import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct ClearApiCredentialsMethodHandler: MethodHandler {

    enum Argument: String {
        case audience
        case scope
    }

    let credentialsManager: CredentialsManager

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let audience = arguments[Argument.audience] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.audience.rawValue)))
        }
        let scope = arguments[Argument.scope] as? String

        do {
            try self.credentialsManager.clear(forAudience: audience, scope: scope)
            callback(nil)
        } catch {
            callback(FlutterError(from: (error as? CredentialsManagerError) ?? .unknown))
        }
    }

}
