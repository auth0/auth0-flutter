import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

typealias MfaClientProvider = (_ account: Account) -> MFAClient
typealias MfaMethodHandlerProvider = (_ method: MfaHandler.Method, _ client: MFAClient) -> MethodHandler

public class MfaHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case getAuthenticators = "mfa#getAuthenticators"
        case enrollTotp = "mfa#enrollTotp"
        case enrollPhone = "mfa#enrollPhone"
        case enrollEmail = "mfa#enrollEmail"
        case enrollPush = "mfa#enrollPush"
        case challenge = "mfa#challenge"
        case verify = "mfa#verify"
    }

    private static let channelName = "auth0.com/auth0_flutter/mfa"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = MfaHandler()

        #if os(iOS)
        let channel = FlutterMethodChannel(name: MfaHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: MfaHandler.channelName,
                                           binaryMessenger: registrar.messenger)
        #endif

        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var clientProvider: MfaClientProvider = { account in
        return Auth0.mfa(clientId: account.clientId, domain: account.domain)
    }

    var methodHandlerProvider: MfaMethodHandlerProvider = { method, client in
        switch method {
        case .getAuthenticators: return MfaGetAuthenticatorsMethodHandler(client: client)
        case .enrollTotp: return MfaEnrollTotpMethodHandler(client: client)
        case .enrollPhone: return MfaEnrollPhoneMethodHandler(client: client)
        case .enrollEmail: return MfaEnrollEmailMethodHandler(client: client)
        case .enrollPush: return MfaEnrollPushMethodHandler(client: client)
        case .challenge: return MfaChallengeMethodHandler(client: client)
        case .verify: return MfaVerifyMethodHandler(client: client)
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
              UserAgent(from: userAgentDictionary) != nil else {
            return result(FlutterError(from: .userAgentMissing))
        }
        guard let method = Method(rawValue: call.method) else {
            return result(FlutterMethodNotImplemented)
        }
        guard arguments["mfaToken"] is String else {
            return result(FlutterError(from: .requiredArgumentMissing("mfaToken")))
        }

        let client = clientProvider(account)
        let methodHandler = methodHandlerProvider(method, client)

        methodHandler.handle(with: arguments, callback: result)
    }
}
