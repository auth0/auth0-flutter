import Foundation
import Flutter
import Auth0

struct WebAuthLoginMethodHandler: MethodHandler {
    enum Argument: String {
        case scopes
        case parameters
        case useEphemeralSession
        case audience
        case redirectUrl
        case organizationId
        case invitationUrl
        case leeway
        case issuer
        case maxAge
        case useSafariViewController
    }

    let client: WebAuth

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let useEphemeralSession = arguments[Argument.useEphemeralSession] as? Bool else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.useEphemeralSession.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        var webAuth = client
            .scope(scopes.asSpaceSeparatedString)
            .parameters(parameters)

        if useEphemeralSession {
            webAuth = webAuth.useEphemeralSession()
        }

        if let audience = arguments[Argument.audience] as? String {
            webAuth = webAuth.audience(audience)
        }

        if let redirectURL = arguments[Argument.redirectUrl] as? String, let url = URL(string: redirectURL) {
            webAuth = webAuth.redirectURL(url)
        }

        if let organizationId = arguments[Argument.organizationId] as? String {
            webAuth = webAuth.organization(organizationId)
        }

        if let invitationURL = arguments[Argument.invitationUrl] as? String,
           let url = URL(string: invitationURL) {
            webAuth = webAuth.invitationURL(url)
        }

        if let leeway = arguments[Argument.leeway] as? Int {
            webAuth = webAuth.leeway(leeway)
        }

        if let issuer = arguments[Argument.issuer] as? String {
            webAuth = webAuth.issuer(issuer)
        }

        if let maxAge = arguments[Argument.maxAge] as? Int {
            webAuth = webAuth.maxAge(maxAge)
        }
        
        if let safariViewControllerDictionary = arguments[SafariViewController.key] as? [String: Any?] {
            let safariViewController = SafariViewController(from: safariViewControllerDictionary)
            
            webAuth = webAuth.provider(WebAuthentication.safariProvider(style: safariViewController.presentationStyle ?? UIModalPresentationStyle.fullScreen))
        }

        webAuth.start {
            switch $0 {
            case let .success(credentials): callback(result(from: credentials))
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
