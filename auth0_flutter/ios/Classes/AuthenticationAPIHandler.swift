import Flutter

class AuthenticationAPIHandler: NSObject, FlutterPlugin {
    enum Method: String, RawRepresentable {
        case login = "auth#login"
        case userInfo = "auth#userInfo"
        case signup = "auth#signUp"
        case renewAccessToken = "auth#renewAccessToken"
        case resetPassword = "auth#resetPassword"
    }

    private static let channelName = "auth0.com/auth0_flutter/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = AuthenticationAPIHandler()
        let channel = FlutterMethodChannel(name: AuthenticationAPIHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch Method(rawValue: call.method) {
        case .login: self.login(call, result)
        case .userInfo: self.userInfo(call, result)
        case .signup: self.signup(call, result)
        case .renewAccessToken: self.renewAccessToken(call, result)
        case .resetPassword: self.resetPassword(call, result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func login(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result("Auth Login Success")
    }

    private func userInfo(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result("Auth UserInfo Success")
    }

    private func signup(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result("Auth Signup Success")
    }

    private func renewAccessToken(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result("Auth Renew Access Token Success")
    }

    private func resetPassword(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result("Auth Reset Password Success")
    }
}
