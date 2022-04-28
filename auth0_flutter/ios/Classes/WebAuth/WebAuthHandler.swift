import Flutter
import Auth0

// MARK: - Providers

typealias WebAuthClientProvider = (_ account: Account, _ userAgent: UserAgent) -> WebAuth
typealias WebAuthMethodHandlerProvider = (_ method: WebAuthHandler.Method, _ client: WebAuth) -> MethodHandler

// MARK: - Web Auth Handler

public class WebAuthHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }
    private static let channelName = "auth0.com/auth0_flutter/web_auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = WebAuthHandler()
        let channel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var clientProvider: WebAuthClientProvider = { account, userAgent in
        var client = Auth0.webAuth(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return client
    }

    var methodHandlerProvider: WebAuthMethodHandlerProvider = { method, client in
        switch method {
        case .login: return WebAuthLoginMethodHandler(client: client)
        case .logout: return WebAuthLogoutMethodHandler(client: client)
        }
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
        guard let method = Method(rawValue: call.method) else {
            return result(FlutterMethodNotImplemented)
        }

        let client = clientProvider(account, userAgent)
        let methodHandler = methodHandlerProvider(method, client)

        methodHandler.handle(with: arguments, callback: result)
    }
}
