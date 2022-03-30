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
    let webAuthChannel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                              binaryMessenger: registrar.messenger())
    let webAuthHandler = WebAuthHandler()
    registrar.addMethodCallDelegate(webAuthHandler, channel: webAuthChannel)
  }

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
    let authenticationAPIChannel = FlutterMethodChannel(name: AuthenticationAPIHandler.channelName,
                                                        binaryMessenger: registrar.messenger())
    let authenticationAPIHandler = AuthenticationAPIHandler()
    registrar.addMethodCallDelegate(authenticationAPIHandler, channel: authenticationAPIChannel)
  }

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

  private let methodCallHandlers: [FlutterPlugin] = [WebAuthHandler(), AuthenticationAPIHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    WebAuthHandler.register(with: registrar)
    AuthenticationAPIHandler.register(with: registrar)
  }

}
