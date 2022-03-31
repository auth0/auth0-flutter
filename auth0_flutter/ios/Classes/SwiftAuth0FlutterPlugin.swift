import Foundation
import Flutter
import UIKit
import Auth0
import JWTDecode

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

  private func login(_ call: FlutterMethodCall, _ callback: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let clientId = arguments["clientId"] as? String,
          let domain = arguments["domain"] as? String,
          let scopes = arguments["scopes"] as? [String],
          let parameters = arguments["parameters"] as? [String: String],
          let useEphemeralSession = arguments["useEphemeralSession"] as? Bool
    else {
      return callback(["error": "ERROR"])
    }

    var webAuth = Auth0
      .webAuth(clientId: clientId, domain: domain)
      .scope(scopes.joined(separator: " "))
      .parameters(parameters)

    if useEphemeralSession {
      webAuth = webAuth.useEphemeralSession()
    }

    if let audience = arguments["audience"] as? String {
      webAuth = webAuth.audience(audience)
    }

    if let redirectURL = arguments["redirectUri"] as? String, let url = URL(string: redirectURL) {
      webAuth = webAuth.redirectURL(url)
    }

    if let organizationId = arguments["organizationId"] as? String {
      webAuth = webAuth.organization(organizationId)
    }

    if let invitationURL = arguments["invitationUrl"] as? String, let url = URL(string: invitationURL) {
      webAuth = webAuth.invitationURL(url)
    }

    if let leeway = arguments["leeway"] as? Int {
      webAuth = webAuth.leeway(leeway)
    }

    if let issuer = arguments["issuer"] as? String {
      webAuth = webAuth.issuer(issuer)
    }

    if let maxAge = arguments["maxAge"] as? Int {
      webAuth = webAuth.maxAge(maxAge)
    }

    webAuth.start { result in
      switch result {
      case let .success(credentials):
        do {
          let jwt = try decode(jwt: credentials.idToken)
          let data: [String: Any?] = [
            "accessToken": credentials.accessToken,
            "idToken": credentials.idToken,
            "refreshToken": credentials.refreshToken,
            "userProfile": jwt.body,
            "expiresIn": credentials.expiresIn.timeIntervalSince1970,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
          ]
          callback(data)
        } catch {
          callback(["error": "ERROR"])
        }
      case let .failure(error): callback(["error": String(describing: error)])
      }
    }
  }

  private func logout(_ call: FlutterMethodCall, _ callback: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let clientId = arguments["clientId"] as? String,
          let domain = arguments["domain"] as? String
    else {
      return callback(["error": "ERROR"])
    }

    var webAuth = Auth0.webAuth(clientId: clientId, domain: domain)

    if let returnTo = arguments["returnTo"] as? String, let url = URL(string: returnTo) { 
      webAuth = webAuth.redirectURL(url)
    }

    webAuth.clearSession { result in
      switch result {
      case .success: callback(nil)
      case let .failure(error): callback(["error": String(describing: error)])
      }
    }
  }
}

class AuthenticationAPIHandler: NSObject, FlutterPlugin { 

  public enum Method: String, RawRepresentable { 
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

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {

  private let methodCallHandlers: [FlutterPlugin] = [WebAuthHandler(), AuthenticationAPIHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    WebAuthHandler.register(with: registrar)
    AuthenticationAPIHandler.register(with: registrar)
  }

}
