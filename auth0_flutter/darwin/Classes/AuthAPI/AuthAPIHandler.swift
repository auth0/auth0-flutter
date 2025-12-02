import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - Providers

typealias AuthAPIClientProvider = (_ account: Account, _ userAgent: UserAgent, _ arguments: [String: Any]) -> Authentication
typealias AuthAPIMethodHandlerProvider = (_ method: AuthAPIHandler.Method, _ client: Authentication) -> MethodHandler

// MARK: - Auth Auth Handler

public class AuthAPIHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case loginWithUsernameOrEmail = "auth#login"
        case loginWithOTP = "auth#loginOtp"
        case multifactorChallenge = "auth#multifactorChallenge"
        case signup = "auth#signUp"
        case userInfo = "auth#userInfo"
        case renew = "auth#renew"
        case resetPassword = "auth#resetPassword"
        case passwordlessWithEmail = "auth#passwordlessWithEmail"
        case passwordlessWithPhoneNumber = "auth#passwordlessWithPhoneNumber"
        case loginWithEmailCode = "auth#loginWithEmail"
        case loginWithSMSCode = "auth#loginWithPhoneNumber"
        case getDPoPHeaders = "auth#getDPoPHeaders"
        case clearDPoPKey = "auth#clearDPoPKey"
    }

    private static let channelName = "auth0.com/auth0_flutter/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = AuthAPIHandler()

        #if os(iOS)
        let channel = FlutterMethodChannel(name: AuthAPIHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: AuthAPIHandler.channelName,
                                           binaryMessenger: registrar.messenger)
        #endif

        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var clientProvider: AuthAPIClientProvider = { account, userAgent, arguments in
        var client = Auth0.authentication(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        
        // Enable DPoP if requested
        let useDPoP = arguments["useDPoP"] as? Bool ?? false
        if useDPoP {
            client = client.useDPoP()
        }
        
        return client
    }

    var methodHandlerProvider: AuthAPIMethodHandlerProvider = { method, client in
        switch method {
        case .loginWithUsernameOrEmail: return AuthAPILoginUsernameOrEmailMethodHandler(client: client)
        case .loginWithOTP: return AuthAPILoginWithOTPMethodHandler(client: client)
        case .multifactorChallenge: return AuthAPIMultifactorChallengeMethodHandler(client: client)
        case .signup: return AuthAPISignupMethodHandler(client: client)
        case .userInfo: return AuthAPIUserInfoMethodHandler(client: client)
        case .renew: return AuthAPIRenewMethodHandler(client: client)
        case .resetPassword: return AuthAPIResetPasswordMethodHandler(client: client)
        case .passwordlessWithEmail: return AuthAPIPasswordlessEmailMethodHandler(client: client)
        case .passwordlessWithPhoneNumber: return AuthAPIPasswordlessPhoneNumberMethodHandler(client: client)
        case .loginWithEmailCode: return AuthAPILoginWithEmailMethodHandler(client: client)
        case .loginWithSMSCode: return AuthAPILoginWithPhoneNumberMethodHandler(client: client)
        case .getDPoPHeaders: return AuthAPIGetDPoPHeadersMethodHandler(client: client)
        case .clearDPoPKey: return AuthAPIClearDPoPKeyMethodHandler(client: client)
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

        let client = clientProvider(account, userAgent, arguments)
        let methodHandler = methodHandlerProvider(method, client)

        methodHandler.handle(with: arguments, callback: result)
    }
}
