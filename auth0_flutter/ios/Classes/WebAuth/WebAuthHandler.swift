import Flutter
import Auth0

// MARK: - Web Auth Handler

public class WebAuthHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }

    var methodHandler: MethodHandler? // For testing

    private static let channelName = "auth0.com/auth0_flutter/web_auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = WebAuthHandler()
        let channel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(FlutterError(from: .argumentsMissing))
        }
        guard let accountDictionary = arguments[Account.key] as? [String: String],
              let account = Account(from: accountDictionary) else {
            return result(FlutterError(from: .accountMissing))
        }
        guard let userAgentDictionary = arguments[UserAgent.key] as? [String: String],
              let userAgent = UserAgent(from: userAgentDictionary) else {
            return result(FlutterError(from: .userAgentMissing))
        }

        let client = makeClient(account: account, userAgent: userAgent)

        switch Method(rawValue: call.method) {
        case .login: callLogin(with: arguments, using: client, result: result)
        case .logout: callLogout(with: arguments, using: client, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    func makeClient(account: Account, userAgent: UserAgent) -> WebAuth {
        var client = Auth0.webAuth(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return client
    }
}

private extension WebAuthHandler {
    func callLogin(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandler ?? WebAuthLoginMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callLogout(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandler ?? WebAuthLogoutMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }
}
