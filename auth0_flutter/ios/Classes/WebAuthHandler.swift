import Foundation
import Flutter
import Auth0

extension FlutterError {
    convenience init(from webAuthError: WebAuthError) {
        var code: String
        switch webAuthError {
        case .noBundleIdentifier: code = "NO_BUNDLE_IDENTIFIER"
        case .invalidInvitationURL: code = "INVALID_INVITATION_URL"
        case .userCancelled: code = "USER_CANCELLED"
        case .noAuthorizationCode: code = "NO_AUTHORIZATION_CODE"
        case .pkceNotAllowed: code = "PKCE_NOT_ALLOWED"
        case .idTokenValidationFailed: code = "ID_TOKEN_VALIDATION_FAILED"
        case .other: code = "OTHER"
        default: code = "UNKNOWN"
        }
        self.init(code: code, message: String(describing: webAuthError), details: webAuthError.details)
    }
}

struct WebAuthLoginMethodHandler: MethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let scopes = arguments["scopes"] as? [String],
              let parameters = arguments["parameters"] as? [String: String],
              let useEphemeralSession = arguments["useEphemeralSession"] as? Bool else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
        }

        var webAuth = client.parameters(parameters)

        if !scopes.isEmpty {
            webAuth = webAuth.scope(scopes.joined(separator: " "))
        }

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

        webAuth.start {
            switch $0 {
            case let .success(credentials): callback(result(from: credentials))
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}

struct WebAuthLogoutMethodHandler: MethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        var webAuth = client

        if let returnTo = arguments["returnTo"] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

        webAuth.clearSession {
            switch $0 {
            case .success: callback(nil)
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}

public class WebAuthHandler: NSObject { 
    enum Method: String, RawRepresentable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }

    var loginMethodHandler: MethodHandler?
    var logoutMethodHandler: MethodHandler?

    private static let channelName = "auth0.com/auth0_flutter/web_auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = WebAuthHandler()
        let channel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let clientId = arguments["clientId"] as? String,
              let domain = arguments["domain"] as? String else {
            return result(FlutterError(from: .requiredArgumentsMissing))
        }

        let webAuth = Auth0.webAuth(clientId: clientId, domain: domain)

        switch Method(rawValue: call.method) {
        case .login:
            let loginHandler = loginMethodHandler ?? WebAuthLoginMethodHandler(client: webAuth)
            loginHandler.handle(with: arguments, callback: result)
        case .logout:
            let logoutHandler = logoutMethodHandler ?? WebAuthLogoutMethodHandler(client: webAuth)
            logoutHandler.handle(with: arguments, callback: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}

extension WebAuthHandler: FlutterPlugin {}
