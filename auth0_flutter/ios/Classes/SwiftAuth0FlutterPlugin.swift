import Flutter
import UIKit

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {

  private let WEBAUTH_LOGIN_METHOD = "webAuth#login"
  private let WEBAUTH_LOGOUT_METHOD = "webAuth#logout"
  private let AUTH_LOGIN_METHOD = "auth#login"
  private let AUTH_CODEEXCHANGE_METHOD = "auth#codeExchange"
  private let AUTH_USERINFO_METHOD = "auth#userInfo"
  private let AUTH_SIGNUP_METHOD = "auth#signUp"
  private let AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
  private let AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "auth0.com/auth0_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftAuth0FlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case WEBAUTH_LOGIN_METHOD: result({
        "accessToken": "Access Token",
        "idToken": "ID Token",
        "refreshToken": "Refresh Token",
        "userProfile": ["name": "John Doe"],
        "expiresIn": 10,
        "scopes": ["a", "b"],
      })
      case WEBAUTH_LOGOUT_METHOD: result("Web Auth Logout Success")
      case AUTH_LOGIN_METHOD: result("Auth Login Success")
      case AUTH_CODEEXCHANGE_METHOD: result("Auth Code Exchange Success")
      case AUTH_USERINFO_METHOD: result("Auth UserInfo Success")
      case AUTH_SIGNUP_METHOD: result("Auth Signup Success")
      case AUTH_RENEWACCESSTOKEN_METHOD: result("Auth Renew Access Token Success")
      case AUTH_RESETPASSWORD_METHOD: result("Auth Reset Password Success")
      default: result("Unknown Method")
    }
  }
}
