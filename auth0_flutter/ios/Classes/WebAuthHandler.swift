import Auth0
import Flutter
import Foundation

protocol WebAuthMethodHandler: MethodHandler {
    var client: WebAuth { get }
    func failure(from webAuthError: WebAuthError) -> [String: Any?]
}

extension WebAuthMethodHandler { 
    func failure(from webAuthError: WebAuthError) -> [String: Any?] {
        var code: String
        switch webAuthError {
        case .noBundleIdentifier: code = "noBundleIdentifier"
        case .invalidInvitationURL: code = "invalidInvitationURL"
        case .userCancelled: code = "userCancelled"
        case .noAuthorizationCode: code = "noAuthorizationCode"
        case .pkceNotAllowed: code = "pkceNotAllowed"
        case .idTokenValidationFailed: code = "idTokenValidationFailed"
        case .other: code = "other"
        default: code = "unknown"
        }
        let error: [String: Any] = ["code": code, "message": String(describing: webAuthError)]
        return errorResult(with: error)
    }
}

struct WebAuthLoginMethodHandler: WebAuthMethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let scopes = arguments["scopes"] as? [String],
              let parameters = arguments["parameters"] as? [String: String],
              let useEphemeralSession = arguments["useEphemeralSession"] as? Bool
        else {
            return callback(errorResult(.missingRequiredArguments))
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

        webAuth.start { result in
            switch result {
            case let .success(credentials): callback(self.result(from: credentials))
            case let .failure(error): callback(self.failure(from: error))
            }
        }
    }
}

struct WebAuthLogoutMethodHandler: WebAuthMethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        var webAuth = client

        if let returnTo = arguments["returnTo"] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

        webAuth.clearSession { result in
            switch result {
            case .success: callback(self.successResult())
            case let .failure(error): callback(self.failure(from: error))
            }
        }
    }
}

class WebAuthHandler: NSObject { 
    enum Method: String, RawRepresentable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }

    var loginMethodHandler: WebAuthMethodHandler?
    var logoutMethodHandler: WebAuthMethodHandler?

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
              let domain = arguments["domain"] as? String
        else {
            return result(errorResult(.missingRequiredArguments))
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
extension WebAuthHandler: ErrorResulting {}
