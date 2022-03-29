import Flutter
import UIKit

public class SwiftAuth0FlutterWebAuthMethodCallHandler: NSObject, FlutterPlugin {

  private let WEBAUTH_LOGIN_METHOD = "webAuth#login"
  private let WEBAUTH_LOGOUT_METHOD = "webAuth#logout"

  public static func register(with registrar: FlutterPluginRegistrar) {}

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case WEBAUTH_LOGIN_METHOD: result([
        "accessToken": "Access Token",
        "idToken": "ID Token",
        "refreshToken": "Refresh Token",
        "userProfile": ["name": "John Doe"],
        "expiresIn": 10,
        "scopes": ["a", "b"],
      ])
      case WEBAUTH_LOGOUT_METHOD: result("Web Auth Logout Success")
      default: result(FlutterMethodNotImplemented)
    }
  }
}

public class SwiftAuth0FlutterAuthMethodCallHandler: NSObject, FlutterPlugin {

  private let AUTH_LOGIN_METHOD = "auth#login"
  private let AUTH_CODEEXCHANGE_METHOD = "auth#codeExchange"
  private let AUTH_USERINFO_METHOD = "auth#userInfo"
  private let AUTH_SIGNUP_METHOD = "auth#signUp"
  private let AUTH_RENEWACCESSTOKEN_METHOD = "auth#renewAccessToken"
  private let AUTH_RESETPASSWORD_METHOD = "auth#resetPassword"

  public static func register(with registrar: FlutterPluginRegistrar) {}

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
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

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {

  private let methodCallHandlers: [FlutterPlugin] = [SwiftAuth0FlutterWebAuthMethodCallHandler(), SwiftAuth0FlutterAuthMethodCallHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let webAuthMethodChannel = FlutterMethodChannel(name: "auth0.com/auth0_flutter/web_auth", binaryMessenger: registrar.messenger())
    let webAuthMethodCallHandler =  SwiftAuth0FlutterWebAuthMethodCallHandler()
    registrar.addMethodCallDelegate(webAuthMethodCallHandler, channel: webAuthMethodChannel);

    let authMethodChannel = FlutterMethodChannel(name: "auth0.com/auth0_flutter/auth", binaryMessenger: registrar.messenger())
    let authMethodCallHandler =  SwiftAuth0FlutterAuthMethodCallHandler()
    registrar.addMethodCallDelegate(authMethodCallHandler, channel: authMethodChannel);
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {}
}
