import Flutter
import UIKit
import Auth0

class WebAuthHandler: NSObject, FlutterPlugin { 

  public enum Method: String, RawRepresentable { 
    case login = "webAuth#login"
    case logout = "webAuth#logout"
  }

  private static let channelName = "auth0.com/auth0_flutter/web_auth"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let handler = WebAuthHandler()
    let channel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                       binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(handler, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch Method(rawValue: call.method) {
    case .login: self.login(call, result)
    case .logout: self.logout(call, result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func login(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) { 
    result([
      "accessToken": "Access Token",
      "idToken": "ID Token",
      "refreshToken": "Refresh Token",
      "userProfile": ["name": "John Doe"],
      "expiresIn": 10,
      "scopes": ["a", "b"],
    ])
  }

  private func logout(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) { 
    result("Web Auth Logout Success")
  }

}

class AuthenticationAPIHandler: NSObject, FlutterPlugin { 

  public enum Method: String, RawRepresentable { 
    case login = "auth#login"
    case codeExchange = "auth#codeExchange"
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
    case .codeExchange: self.codeExchange(call, result)
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

  private func codeExchange(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) { 
    result("Auth Code Exchange Success")
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

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {

  private let methodCallHandlers: [FlutterPlugin] = [WebAuthHandler(), AuthenticationAPIHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    WebAuthHandler.register(with: registrar)
    AuthenticationAPIHandler.register(with: registrar)
  }

}
