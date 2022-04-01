import Auth0
import Flutter
import Foundation
import JWTDecode

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
        return self.wrap(error: error)
    }
}

struct WebAuthLoginMethodHandler: WebAuthMethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let scopes = arguments["scopes"] as? [String],
              let parameters = arguments["parameters"] as? [String: String],
              let useEphemeralSession = arguments["useEphemeralSession"] as? Bool
        else {
            return callback(self.failure(code: "missingRequiredArguments",
                                         message: "One or more required parameters are missing."))
        }

        var webAuth = self.client.parameters(parameters)

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
            case let .success(credentials):
                do {
                    callback(try self.success(from: credentials))
                } catch {
                    callback(self.failure(code: "idTokenDecodingFailed",
                                          message: "Unable to decode the ID Token."))
                }
            case let .failure(error):
                callback(self.failure(from: error))
            }
        }
    }
}

extension WebAuthLoginMethodHandler {
    func success(from credentials: Credentials) throws -> [String: Any?] {
        let jwt = try decode(jwt: credentials.idToken)
        let result: [String: Any?] = [
            "accessToken": credentials.accessToken,
            "idToken": credentials.idToken,
            "refreshToken": credentials.refreshToken,
            "userProfile": jwt.body,
            "expiresIn": credentials.expiresIn.timeIntervalSince1970,
            "scopes": credentials.scope?.split(separator: " ").map(String.init),
        ]
        return self.wrap(result: result)
    }
}

struct WebAuthLogoutMethodHandler: WebAuthMethodHandler {
    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        var webAuth = self.client

        if let returnTo = arguments["returnTo"] as? String, let url = URL(string: returnTo) {
            webAuth = webAuth.redirectURL(url)
        }

        webAuth.clearSession { result in
            switch result {
            case .success: callback(self.success())
            case let .failure(error): callback(self.failure(from: error))
            }
        }
    }
}

extension WebAuthLogoutMethodHandler {
    func success() -> [String: Any?] {
        return self.wrap(result: nil)
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
            return result(self.failure(code: "missingRequiredArguments",
                                       message: "One or more required parameters are missing."))
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
extension WebAuthHandler: Failable {}
