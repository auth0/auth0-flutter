import Foundation
import Flutter
import Auth0

// MARK: - Extensions

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

// MARK: - Method Handlers

struct WebAuthLoginMethodHandler: MethodHandler {
    enum Argument: String {
        case scopes
        case parameters
        case useEphemeralSession
        case audience
        case redirectUri
        case organizationId
        case invitationUrl
        case leeway
        case issuer
        case maxAge
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let useEphemeralSession = arguments[Argument.useEphemeralSession.rawValue] as? Bool else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.useEphemeralSession.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes.rawValue] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters.rawValue] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        var webAuth = client.parameters(parameters)

        if !scopes.isEmpty {
            webAuth = webAuth.scope(scopes.asSpaceSeparatedString)
        }

        if useEphemeralSession {
            webAuth = webAuth.useEphemeralSession()
        }

        if let audience = arguments[Argument.audience.rawValue] as? String {
            webAuth = webAuth.audience(audience)
        }

        if let redirectURL = arguments[Argument.redirectUri.rawValue] as? String, let url = URL(string: redirectURL) {
            webAuth = webAuth.redirectURL(url)
        }

        if let organizationId = arguments[Argument.organizationId.rawValue] as? String {
            webAuth = webAuth.organization(organizationId)
        }

        if let invitationURL = arguments[Argument.invitationUrl.rawValue] as? String,
            let url = URL(string: invitationURL) {
            webAuth = webAuth.invitationURL(url)
        }

        if let leeway = arguments[Argument.leeway.rawValue] as? Int {
            webAuth = webAuth.leeway(leeway)
        }

        if let issuer = arguments[Argument.issuer.rawValue] as? String {
            webAuth = webAuth.issuer(issuer)
        }

        if let maxAge = arguments[Argument.maxAge.rawValue] as? Int {
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
    enum Argument: String {
        case returnTo
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        var webAuth = client

        if let returnTo = arguments[Argument.returnTo.rawValue] as? String, let url = URL(string: returnTo) {
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

// MARK: - Web Auth Handler

public class WebAuthHandler: NSObject, FlutterPlugin {
    enum Argument: String {
        case clientId
        case domain
    }

    enum Method: String, CaseIterable {
        case login = "webAuth#login"
        case logout = "webAuth#logout"
    }

    var methodHandlers: [Method: MethodHandler] = [:]

    private static let channelName = "auth0.com/auth0_flutter/web_auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = WebAuthHandler()
        let channel = FlutterMethodChannel(name: WebAuthHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(FlutterError(from: .argumentsMissing))
        }
        guard let clientId = arguments[Argument.clientId.rawValue] as? String else {
            return result(FlutterError(from: .requiredArgumentMissing(Argument.clientId.rawValue)))
        }
        guard let domain = arguments[Argument.domain.rawValue] as? String else {
            return result(FlutterError(from: .requiredArgumentMissing(Argument.domain.rawValue)))
        }

        let webAuth = Auth0.webAuth(clientId: clientId, domain: domain)

        switch Method(rawValue: call.method) {
        case .login: callLogin(with: arguments, using: webAuth, result: result)
        case .logout: callLogout(with: arguments, using: webAuth, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}

private extension WebAuthHandler {
    func callLogin(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandlers[.login] ?? WebAuthLoginMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callLogout(with arguments: [String: Any], using client: WebAuth, result: @escaping FlutterResult) {
        let handler = methodHandlers[.logout] ?? WebAuthLogoutMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }
}
