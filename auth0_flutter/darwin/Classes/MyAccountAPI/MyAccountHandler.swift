import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

typealias MyAccountClientProvider = (_ account: Account, _ userAgent: UserAgent, _ accessToken: String, _ useDPoP: Bool) -> MyAccount
typealias MyAccountMethodHandlerProvider = (_ method: MyAccountHandler.Method, _ client: MyAccount) -> MethodHandler

public class MyAccountHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case getAuthenticationMethods = "myAccount#getAuthenticationMethods"
        case getAuthenticationMethod = "myAccount#getAuthenticationMethod"
        case deleteAuthenticationMethod = "myAccount#deleteAuthenticationMethod"
        case getFactors = "myAccount#getFactors"
        case enrollPhone = "myAccount#enrollPhone"
        case enrollEmail = "myAccount#enrollEmail"
        case enrollTotp = "myAccount#enrollTotp"
        case enrollPush = "myAccount#enrollPush"
        case enrollRecoveryCode = "myAccount#enrollRecoveryCode"
        case verifyOtp = "myAccount#verifyOtp"
        case confirmEnrollment = "myAccount#confirmEnrollment"
        case updateAuthenticationMethod = "myAccount#updateAuthenticationMethod"
    }

    private static let channelName = "auth0.com/auth0_flutter/my_account"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = MyAccountHandler()

        #if os(iOS)
        let channel = FlutterMethodChannel(name: MyAccountHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: MyAccountHandler.channelName,
                                           binaryMessenger: registrar.messenger)
        #endif

        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    var clientProvider: MyAccountClientProvider = { account, userAgent, accessToken, useDPoP in
        var client = Auth0.myAccount(token: accessToken, domain: account.domain)
        if useDPoP {
            client = client.useDPoP()
        }
        return client
    }

    var methodHandlerProvider: MyAccountMethodHandlerProvider = { method, client in
        switch method {
        case .getAuthenticationMethods: return MyAccountGetAuthMethodsMethodHandler(client: client)
        case .getAuthenticationMethod: return MyAccountGetAuthMethodMethodHandler(client: client)
        case .deleteAuthenticationMethod: return MyAccountDeleteAuthMethodMethodHandler(client: client)
        case .getFactors: return MyAccountGetFactorsMethodHandler(client: client)
        case .enrollPhone: return MyAccountEnrollPhoneMethodHandler(client: client)
        case .enrollEmail: return MyAccountEnrollEmailMethodHandler(client: client)
        case .enrollTotp: return MyAccountEnrollTotpMethodHandler(client: client)
        case .enrollPush: return MyAccountEnrollPushMethodHandler(client: client)
        case .enrollRecoveryCode: return MyAccountEnrollRecoveryCodeMethodHandler(client: client)
        case .verifyOtp: return MyAccountVerifyOtpMethodHandler(client: client)
        case .confirmEnrollment: return MyAccountConfirmEnrollmentMethodHandler(client: client)
        case .updateAuthenticationMethod: return MyAccountUpdateAuthMethodMethodHandler(client: client)
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
        guard let accessToken = arguments["accessToken"] as? String else {
            return result(FlutterError(from: .requiredArgumentMissing("accessToken")))
        }

        let useDPoP = arguments["useDPoP"] as? Bool ?? false
        let client = clientProvider(account, userAgent, accessToken, useDPoP)
        let methodHandler = methodHandlerProvider(method, client)

        methodHandler.handle(with: arguments, callback: result)
    }
}
