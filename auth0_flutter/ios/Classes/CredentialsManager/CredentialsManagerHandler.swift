import Flutter
import Auth0

// MARK: - Providers

typealias CredentialsManagerMethodHandlerProvider = (_ method: WebAuthHandler.Method) -> MethodHandler

// MARK: - Web Auth Handler

public class CredentialsManagerHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case clear = "credentialsManager#clearCredentials"
    }
    private static let channelName = "auth0.com/auth0_flutter/credentials_manager"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = CredentialsManagerHandler()
        let channel = FlutterMethodChannel(name: CredentialsManagerHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var methodHandlerProvider: CredentialsManagerMethodHandlerProvider = { method in
        switch method {
        case .clear: return CredentialsManagerClearMethodHandler()
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

        let methodHandler = methodHandlerProvider(method)

        methodHandler.handle(with: arguments, callback: result)
    }
}
