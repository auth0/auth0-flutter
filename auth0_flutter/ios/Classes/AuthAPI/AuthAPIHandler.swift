import Flutter
import Auth0

public class AuthAPIHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case loginWithUsernameOrEmail = "auth#login"
        case signup = "auth#signUp"
        case userInfo = "auth#userInfo"
        case renewAccessToken = "auth#renewAccessToken"
        case resetPassword = "auth#resetPassword"
    }

    var methodHandler: MethodHandler? // For testing

    private static let channelName = "auth0.com/auth0_flutter/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = AuthAPIHandler()
        let channel = FlutterMethodChannel(name: AuthAPIHandler.channelName,
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
        case .loginWithUsernameOrEmail: callLoginWithUsernameOrEmail(with: arguments, using: client, result: result)
        case .signup: callSignup(with: arguments, using: client, result: result)
        case .userInfo: callUserInfo(with: arguments, using: client, result: result)
        case .renewAccessToken: callRenewAccessToken(with: arguments, using: client, result: result)
        case .resetPassword: callResetPassword(with: arguments, using: client, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    func makeClient(account: Account, userAgent: UserAgent) -> Authentication {
        var client = Auth0.authentication(clientId: account.clientId, domain: account.domain)
        client.using(inLibrary: userAgent.name, version: userAgent.version)
        return client
    }
}

private extension AuthAPIHandler {
    func callLoginWithUsernameOrEmail(with arguments: [String: Any],
                                      using client: Authentication,
                                      result: @escaping FlutterResult) {
        let handler = methodHandler ?? AuthAPILoginUsernameOrEmailMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callSignup(with arguments: [String: Any], using client: Authentication, result: @escaping FlutterResult) {
        let handler = methodHandler ?? AuthAPISignupMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callUserInfo(with arguments: [String: Any], using client: Authentication, result: @escaping FlutterResult) {
        let handler = methodHandler ?? AuthAPIUserInfoMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callRenewAccessToken(with arguments: [String: Any],
                              using client: Authentication,
                              result: @escaping FlutterResult) {
        let handler = methodHandler ?? AuthAPIRenewAccessTokenMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callResetPassword(with arguments: [String: Any],
                           using client: Authentication,
                           result: @escaping FlutterResult) {
        let handler = methodHandler ?? AuthAPIResetPasswordMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }
}
