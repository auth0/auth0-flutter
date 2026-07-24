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
        case customTokenExchange = "auth#customTokenExchange"
        case resetPassword = "auth#resetPassword"
        case passwordlessWithEmail = "auth#passwordlessWithEmail"
        case passwordlessWithPhoneNumber = "auth#passwordlessWithPhoneNumber"
        case loginWithEmailCode = "auth#loginWithEmail"
        case loginWithSMSCode = "auth#loginWithPhoneNumber"
        case ssoExchange = "auth#ssoExchange"
        case passkeyLoginChallenge = "auth#passkeyLoginChallenge"
        case passkeySignupChallenge = "auth#passkeySignupChallenge"
        case passkeyCredentialExchange = "auth#passkeyCredentialExchange"
        case passwordlessChallengeWithEmail = "auth#passwordlessChallengeWithEmail"
        case passwordlessChallengeWithPhoneNumber = "auth#passwordlessChallengeWithPhoneNumber"
        case passwordlessLoginWithOtp = "auth#passwordlessLoginWithOtp"
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
        
        let useDPoP = arguments["useDPoP"] as? Bool ?? false
        if useDPoP {
            client = client.useDPoP()
        }
        
        return client
    }

    // `Authentication.login(withOTP:mfaToken:)` and `Authentication.multifactorChallenge(...)`
    // were removed in Auth0.swift v3. These two method handlers use the dedicated `MFAClient`
    // instead (see Auth0.swift's V3_MIGRATION_GUIDE.md), so they need an `MFAClient` rather than
    // the `Authentication` client passed to every other handler here.
    var mfaClientProvider: (_ account: Account) -> MFAClient = { account in
        return Auth0.mfa(clientId: account.clientId, domain: account.domain)
    }

    var methodHandlerProvider: AuthAPIMethodHandlerProvider = { method, client in
        switch method {
        // `.loginWithOTP` and `.multifactorChallenge` are routed directly to an `MFAClient`-backed
        // handler in `handle(_:result:)` below and never reach this provider; they're only listed
        // here so the switch stays exhaustive over `Method`.
        case .loginWithOTP, .multifactorChallenge: return UnsupportedMethodHandler()
        case .loginWithUsernameOrEmail: return AuthAPILoginUsernameOrEmailMethodHandler(client: client)
        case .signup: return AuthAPISignupMethodHandler(client: client)
        case .userInfo: return AuthAPIUserInfoMethodHandler(client: client)
        case .renew: return AuthAPIRenewMethodHandler(client: client)
        case .customTokenExchange: return AuthAPICustomTokenExchangeMethodHandler(client: client)
        case .resetPassword: return AuthAPIResetPasswordMethodHandler(client: client)
        case .passwordlessWithEmail: return AuthAPIPasswordlessEmailMethodHandler(client: client)
        case .passwordlessWithPhoneNumber: return AuthAPIPasswordlessPhoneNumberMethodHandler(client: client)
        case .loginWithEmailCode: return AuthAPILoginWithEmailMethodHandler(client: client)
        case .loginWithSMSCode: return AuthAPILoginWithPhoneNumberMethodHandler(client: client)
        case .ssoExchange: return SSOExchangeMethodHandler(client: client)
        case .passwordlessChallengeWithEmail: return AuthAPIPasswordlessChallengeEmailMethodHandler(client: client)
        case .passwordlessChallengeWithPhoneNumber: return AuthAPIPasswordlessChallengePhoneNumberMethodHandler(client: client)
        case .passwordlessLoginWithOtp: return AuthAPIPasswordlessLoginWithOtpMethodHandler(client: client)
        #if PASSKEYS_PLATFORM
        case .passkeyLoginChallenge:
            if #available(iOS 16.6, macOS 13.5, visionOS 1.0, *) {
                return AuthAPIPasskeyLoginChallengeMethodHandler(client: client)
            }
            return UnsupportedMethodHandler()
        case .passkeySignupChallenge:
            if #available(iOS 16.6, macOS 13.5, visionOS 1.0, *) {
                return AuthAPIPasskeySignupChallengeMethodHandler(client: client)
            }
            return UnsupportedMethodHandler()
        case .passkeyCredentialExchange:
            if #available(iOS 16.6, macOS 13.5, visionOS 1.0, *) {
                return AuthAPIPasskeyCredentialExchangeMethodHandler(client: client)
            }
            return UnsupportedMethodHandler()
        #else
        case .passkeyLoginChallenge, .passkeySignupChallenge, .passkeyCredentialExchange:
            return UnsupportedMethodHandler()
        #endif
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

        let methodHandler: MethodHandler
        switch method {
        case .loginWithOTP:
            methodHandler = AuthAPILoginWithOTPMethodHandler(client: mfaClientProvider(account))
        case .multifactorChallenge:
            methodHandler = AuthAPIMultifactorChallengeMethodHandler(client: mfaClientProvider(account))
        default:
            let client = clientProvider(account, userAgent, arguments)
            methodHandler = methodHandlerProvider(method, client)
        }

        methodHandler.handle(with: arguments, callback: result)
    }
}
