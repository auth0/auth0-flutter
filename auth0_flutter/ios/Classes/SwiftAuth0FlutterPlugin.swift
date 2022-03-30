import Flutter
import UIKit
import Auth0

class WebAuthMethodCallHandler: NSObject, FlutterPlugin { 

  enum Method: String, RawRepresentable {
    case login = "webAuth#login"
    case logout = "webAuth#logout"
  }

  public static func register(with registrar: FlutterPluginRegistrar) {}

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch Method(rawValue: call.method) {
    case .login: result([
        "accessToken": "Access Token",
        "idToken": "ID Token",
        "refreshToken": "Refresh Token",
        "userProfile": ["name": "John Doe"],
        "expiresIn": 10,
        "scopes": ["a", "b"],
      ])
    case .logout: result("Web Auth Logout Success")
    default: result(FlutterMethodNotImplemented)
    }
  }

}

class AuthenticationAPIMethodCallHandler: NSObject, FlutterPlugin { 

  enum Method: String, RawRepresentable {
    case login = "auth#login"
    case codeExchange = "auth#codeExchange"
    case userInfo = "auth#userInfo"
    case signup = "auth#signUp"
    case renewAccessToken = "auth#renewAccessToken"
    case resetPassword = "auth#resetPassword"
  }

  public static func register(with registrar: FlutterPluginRegistrar) {}

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch Method(rawValue: call.method) {
      case .login: result("Auth Login Success")
      case .codeExchange: result("Auth Code Exchange Success")
      case .userInfo: result("Auth UserInfo Success")
      case .signup: result("Auth Signup Success")
      case .renewAccessToken: result("Auth Renew Access Token Success")
      case .resetPassword: result("Auth Reset Password Success")
      default: result(FlutterMethodNotImplemented)
    }
  }

}

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {

  private let methodCallHandlers: [FlutterPlugin] = [WebAuthMethodCallHandler(), AuthenticationAPIMethodCallHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let webAuthMethodChannel = FlutterMethodChannel(name: "auth0.com/auth0_flutter/web_auth", binaryMessenger: registrar.messenger())
    let webAuthMethodCallHandler = WebAuthMethodCallHandler()
    registrar.addMethodCallDelegate(webAuthMethodCallHandler, channel: webAuthMethodChannel);

    let authMethodChannel = FlutterMethodChannel(name: "auth0.com/auth0_flutter/auth", binaryMessenger: registrar.messenger())
    let authMethodCallHandler = AuthenticationAPIMethodCallHandler()
    registrar.addMethodCallDelegate(authMethodCallHandler, channel: authMethodChannel);
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {}

}
