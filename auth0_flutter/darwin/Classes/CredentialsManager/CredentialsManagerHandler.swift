import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - Providers

typealias CredentialsManagerProvider = (_ apiClient: Authentication, _ arguments: [String: Any]) -> CredentialsManager
typealias CredentialsManagerMethodHandlerProvider = (_ method: CredentialsManagerHandler.Method,
                                                     _ credentialsManager: CredentialsManager) -> MethodHandler

// MARK: - Credentials Manager Handler

public class CredentialsManagerHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case save = "credentialsManager#saveCredentials"
        case hasValid = "credentialsManager#hasValidCredentials"
        case get = "credentialsManager#getCredentials"
        case clear = "credentialsManager#clearCredentials"
    }

    private static let channelName = "auth0.com/auth0_flutter/credentials_manager"
    private static var credentialsManager: CredentialsManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = CredentialsManagerHandler()

        #if os(iOS)
        let channel = FlutterMethodChannel(name: CredentialsManagerHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: CredentialsManagerHandler.channelName,
                                           binaryMessenger: registrar.messenger)
        #endif

        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var apiClientProvider: AuthAPIClientProvider = { account, userAgent in
        var client = Auth0.authentication(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return client
    }

    var credentialsManagerProvider: CredentialsManagerProvider = { apiClient, arguments in
        var instance = CredentialsManagerHandler.credentialsManager ?? CredentialsManager(authentication: apiClient)

        if let localAuthenticationDictionary = arguments[LocalAuthentication.key] as? [String: String?] {
            let localAuthentication = LocalAuthentication(from: localAuthenticationDictionary)
            instance.enableBiometrics(withTitle: localAuthentication.title,
                                      cancelTitle: localAuthentication.cancelTitle,
                                      fallbackTitle: localAuthentication.fallbackTitle)
        }

        CredentialsManagerHandler.credentialsManager = instance
        return instance
    }

    var methodHandlerProvider: CredentialsManagerMethodHandlerProvider = { method, credentialsManager in
        switch method {
        case .save: return CredentialsManagerSaveMethodHandler(credentialsManager: credentialsManager)
        case .hasValid: return CredentialsManagerHasValidMethodHandler(credentialsManager: credentialsManager)
        case .get: return CredentialsManagerGetMethodHandler(credentialsManager: credentialsManager)
        case .clear: return CredentialsManagerClearMethodHandler(credentialsManager: credentialsManager)
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

        let apiClient = apiClientProvider(account, userAgent)
        let credentialsManager = credentialsManagerProvider(apiClient, arguments)
        let methodHandler = methodHandlerProvider(method, credentialsManager)
        methodHandler.handle(with: arguments, callback: result)
    }
}
