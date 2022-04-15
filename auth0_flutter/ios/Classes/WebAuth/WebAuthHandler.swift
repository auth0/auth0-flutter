import Flutter
import Auth0

// MARK: - Web Auth Handler

public class WebAuthHandler: NSObject, FlutterPlugin {
    enum Argument: String {
        case clientId
        case domain
    }

    enum Method: String, CaseIterable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }

    var methodHandlers: [Method: MethodHandler] = [:] // For testing

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
        guard let clientId = arguments[Argument.clientId] as? String else {
            return result(FlutterError(from: .requiredArgumentMissing(Argument.clientId.rawValue)))
        }
        guard let domain = arguments[Argument.domain] as? String else {
            return result(FlutterError(from: .requiredArgumentMissing(Argument.domain.rawValue)))
        }

        let webAuth = Auth0.webAuth(clientId: clientId, domain: domain)

        switch Method(rawValue: call.method) {
        case .login: callLogin(with: arguments, using: webAuth, result: result)
        case .logout: callLogout(with: arguments, using: webAuth, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}

private extension WebAuthHandler {
    func callLogin(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandlers[.login] ?? WebAuthLoginMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callLogout(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandlers[.logout] ?? WebAuthLogoutMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }
}
