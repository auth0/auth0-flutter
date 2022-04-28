import Flutter
import Auth0

// MARK: - Providers

typealias AuthAPIClientProvider = (_ account: Account, _ userAgent: UserAgent) -> Authentication
typealias AuthAPIMethodHandlerProvider = (_ method: AuthAPIHandler.Method, _ client: Authentication) -> MethodHandler

// MARK: - Auth Auth Handler

public class AuthAPIHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case loginWithUsernameOrEmail = "auth#login"
        case signup = "auth#signUp"
        case userInfo = "auth#userInfo"
        case renew = "auth#renew"
        case resetPassword = "auth#resetPassword"
    }

    private static let channelName = "auth0.com/auth0_flutter/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = AuthAPIHandler()
        let channel = FlutterMethodChannel(name: AuthAPIHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var clientProvider: AuthAPIClientProvider = { account, userAgent in
        var client = Auth0.authentication(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return client
    }

    var methodHandlerProvider: AuthAPIMethodHandlerProvider = { method, client in
        switch method {
        case .loginWithUsernameOrEmail: return AuthAPILoginUsernameOrEmailMethodHandler(client: client)
        case .signup: return AuthAPISignupMethodHandler(client: client)
        case .userInfo: return AuthAPIUserInfoMethodHandler(client: client)
        case .renew: return AuthAPIRenewMethodHandler(client: client)
        case .resetPassword: return AuthAPIResetPasswordMethodHandler(client: client)
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
