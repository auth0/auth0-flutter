import Auth0
import SimpleKeychain


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
        case renew = "credentialsManager#renewCredentials"
        case clear = "credentialsManager#clearCredentials"
        case userInfo = "credentialsManager#getUserInfo"
    }
    
    private struct ManagerCacheKey: Equatable {
        let accountDomain: String
        let accountClientId: String
        let storeKey: String
        let accessGroup: String?
        let useDPoP: Bool
        let hasLocalAuth: Bool
    }

    private static let channelName = "auth0.com/auth0_flutter/credentials_manager"
    private static var credentialsManager: CredentialsManager?
    private static var cachedKey: ManagerCacheKey?

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

      func createCredentialManager(_ apiClient: Authentication, _ arguments: [String: Any]) -> CredentialsManager {
        if let configuration = arguments["credentialsManagerConfiguration"] as? [String: Any],
           let iosConfiguration = configuration["ios"] as? [String: String] {

            let storeKey = iosConfiguration["storeKey"] ?? "credentials"
            let accessGroup = iosConfiguration["accessGroup"]
            let accessibilityString = iosConfiguration["accessibility"] ?? "afterFirstUnlock"
            let accessibility = Accessibility(rawValue: accessibilityString as CFString)

            let storage = SimpleKeychain(
                accessGroup: accessGroup,
                accessibility: accessibility
            )
            return CredentialsManager(authentication: apiClient, storeKey: storeKey, storage: storage)
        } else {
            return CredentialsManager(authentication: apiClient)
        }
    }

    var apiClientProvider: AuthAPIClientProvider = { account, userAgent, arguments in
        let useDPoP = arguments["useDPoP"] as? Bool ?? false
        var client = Auth0.authentication(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return useDPoP ? client.useDPoP() : client
    }


    lazy var credentialsManagerProvider: CredentialsManagerProvider = { apiClient, arguments in

        let configuration = arguments["credentialsManagerConfiguration"] as? [String: Any]
        let iosConfiguration = configuration?["ios"] as? [String: String]
        let storeKey = iosConfiguration?["storeKey"] ?? "credentials"
        let accessGroup = iosConfiguration?["accessGroup"]
        let useDPoP = arguments["useDPoP"] as? Bool ?? false
        let hasLocalAuth = arguments[LocalAuthentication.key] != nil
        
        guard let accountDictionary = arguments[Account.key] as? [String: String],
              let account = Account(from: accountDictionary) else {
            return self.createCredentialManager(apiClient, arguments)
        }
        
        let currentKey = ManagerCacheKey(
            accountDomain: account.domain,
            accountClientId: account.clientId,
            storeKey: storeKey,
            accessGroup: accessGroup,
            useDPoP: useDPoP,
            hasLocalAuth: hasLocalAuth
        )
        
        var instance: CredentialsManager
        if let cachedKey = CredentialsManagerHandler.cachedKey,
           cachedKey == currentKey,
           let cachedManager = CredentialsManagerHandler.credentialsManager {
            instance = cachedManager
        } else {
            instance = self.createCredentialManager(apiClient, arguments)
            
            CredentialsManagerHandler.credentialsManager = instance
            CredentialsManagerHandler.cachedKey = currentKey
        }
        
        if let localAuthenticationDictionary = arguments[LocalAuthentication.key] as? [String: String?] {
            let localAuthentication = LocalAuthentication(from: localAuthenticationDictionary)
            instance.enableBiometrics(withTitle: localAuthentication.title,
                                      cancelTitle: localAuthentication.cancelTitle,
                                      fallbackTitle: localAuthentication.fallbackTitle)
        }
        
        return instance
    }

    var methodHandlerProvider: CredentialsManagerMethodHandlerProvider = { method, credentialsManager in
        switch method {
        case .save: return CredentialsManagerSaveMethodHandler(credentialsManager: credentialsManager)
        case .hasValid: return CredentialsManagerHasValidMethodHandler(credentialsManager: credentialsManager)
        case .get: return CredentialsManagerGetMethodHandler(credentialsManager: credentialsManager)
        case .clear: return CredentialsManagerClearMethodHandler(credentialsManager: credentialsManager)
        case .userInfo: return CredentialsManagerUserInfoMethodHandler(credentialsManager: credentialsManager)
        case .renew: return CredentialsManagerRenewMethodHandler(credentialsManager: credentialsManager)
        case .userInfo: return CredentialsManagerUserInfoMethodHandler(credentialsManager: credentialsManager)
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

        let apiClient = apiClientProvider(account, userAgent, arguments)
        let credentialsManager = credentialsManagerProvider(apiClient, arguments)
        let methodHandler = methodHandlerProvider(method, credentialsManager)
        methodHandler.handle(with: arguments, callback: result)
    }

}
