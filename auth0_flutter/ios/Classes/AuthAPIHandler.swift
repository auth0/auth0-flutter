import Flutter
import Auth0

// MARK: - Extensions

extension MethodHandler {
    func result(from databaseUser: DatabaseUser) -> Any? {
        let data: [String: Any?] = [
            "email": databaseUser.email,
            "emailVerified": databaseUser.verified,
            "username": databaseUser.username
        ]
        return data
    }

    func result(from userInfo: UserInfo) -> Any? {
        let data: [String: Any?] = [
            "sub": userInfo.sub,
            "name": userInfo.name,
            "given_name": userInfo.givenName,
            "family_name": userInfo.familyName,
            "middle_name": userInfo.middleName,
            "nickname": userInfo.nickname,
            "preferred_username": userInfo.preferredUsername,
            "profile": userInfo.profile?.absoluteString,
            "picture": userInfo.picture?.absoluteString,
            "website": userInfo.website?.absoluteString,
            "email": userInfo.email,
            "email_verified": userInfo.emailVerified,
            "gender": userInfo.gender,
            "birthdate": userInfo.birthdate,
            "zoneinfo": userInfo.zoneinfo?.identifier,
            "locale": userInfo.locale?.identifier,
            "phone_number": userInfo.phoneNumber,
            "phone_number_verified": userInfo.phoneNumberVerified,
            "address": userInfo.address,
            "updated_at": userInfo.updatedAt?.asISO8601String,
            "custom_claims": userInfo.customClaims
        ]
        return data
    }
}

extension FlutterError {
    convenience init(from authenticationError: AuthenticationError) {
        self.init(code: authenticationError.code,
                  message: String(describing: authenticationError),
                  details: authenticationError.details)
    }
}

// MARK: - Method Handlers

struct AuthAPILoginUsernameOrEmailMethodHandler: MethodHandler {
    enum Argument: String {
        case usernameOrEmail
        case password
        case connectionOrRealm
        case scopes
        case parameters
        case audience
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let usernameOrEmail = arguments[Argument.usernameOrEmail.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.usernameOrEmail.rawValue)))
        }
        guard let password = arguments[Argument.password.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.password.rawValue)))
        }
        guard let connectionOrRealm = arguments[Argument.connectionOrRealm.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connectionOrRealm.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes.rawValue] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters.rawValue] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        let audience = arguments[Argument.audience.rawValue] as? String

        client
            .login(usernameOrEmail: usernameOrEmail,
                   password: password,
                   realmOrConnection: connectionOrRealm,
                   audience: audience,
                   scope: scopes.isEmpty ? Auth0.defaultScope : scopes.asSpaceSeparatedString)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}

struct AuthAPISignupMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case password
        case connection
        case username
        case userMetadata
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }
        guard let password = arguments[Argument.password.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.password.rawValue)))
        }
        guard let connection = arguments[Argument.connection.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }

        let username = arguments[Argument.username.rawValue] as? String
        let userMetadata = arguments[Argument.userMetadata.rawValue] as? [String: Any]

        client
            .signup(email: email,
                    username: username,
                    password: password,
                    connection: connection,
                    userMetadata: userMetadata)
            .start {
                switch $0 {
                case let .success(databaseUser): callback(result(from: databaseUser))
                case let .failure(error): callback(FlutterError(from: error))
                }

            }
    }
}

struct AuthAPIRenewAccessTokenMethodHandler: MethodHandler {
    enum Argument: String {
        case refreshToken
        case scopes
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let refreshToken = arguments[Argument.refreshToken.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.refreshToken.rawValue)))
        }
        guard let scopes = arguments[Argument.scopes.rawValue] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.scopes.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters.rawValue] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .renew(withRefreshToken: refreshToken,
                   scope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}

struct AuthAPIResetPasswordMethodHandler: MethodHandler {
    enum Argument: String {
        case email
        case connection
        case parameters
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments[Argument.email.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.email.rawValue)))
        }
        guard let connection = arguments[Argument.connection.rawValue] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.connection.rawValue)))
        }
        guard let parameters = arguments[Argument.parameters.rawValue] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.parameters.rawValue)))
        }

        client
            .resetPassword(email: email, connection: connection)
            .parameters(parameters)
            .start {
                switch $0 {
                case .success: callback(nil)
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}

// MARK: - Authentication API Handler

public class AuthAPIHandler: NSObject, FlutterPlugin {
    enum Argument: String {
        case clientId
        case domain
    }

    enum Method: String, CaseIterable {
        case loginWithUsernameOrEmail = "auth#login"
        case signup = "auth#signUp"
        case userInfo = "auth#userInfo"
        case renewAccessToken = "auth#renewAccessToken"
        case resetPassword = "auth#resetPassword"
    }

    var methodHandlers: [Method: MethodHandler] = [:]

    private static let channelName = "auth0.com/auth0_flutter/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = AuthAPIHandler()
        let channel = FlutterMethodChannel(name: AuthAPIHandler.channelName,
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

        let client = Auth0.authentication(clientId: clientId, domain: domain)

        switch Method(rawValue: call.method) {
        case .loginWithUsernameOrEmail: callLoginWithUsernameOrEmail(with: arguments, using: client, result: result)
        case .signup: callSignup(with: arguments, using: client, result: result)
        // case .userInfo: callUserInfo(with: arguments, using: client, result: result)
        case .renewAccessToken: callRenewAccessToken(with: arguments, using: client, result: result)
        case .resetPassword: callResetPassword(with: arguments, using: client, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
}

private extension AuthAPIHandler {
    func callLoginWithUsernameOrEmail(with arguments: [String: Any],
                                      using client: Authentication,
                                      result: @escaping FlutterResult) {
        let handler = methodHandlers[.loginWithUsernameOrEmail] ??
            AuthAPILoginUsernameOrEmailMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callSignup(with arguments: [String: Any], using client: Authentication, result: @escaping FlutterResult) {
        let handler = methodHandlers[.signup] ?? AuthAPISignupMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callRenewAccessToken(with arguments: [String: Any],
                              using client: Authentication,
                              result: @escaping FlutterResult) {
        let handler = methodHandlers[.renewAccessToken] ?? AuthAPIRenewAccessTokenMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }

    func callResetPassword(with arguments: [String: Any],
                           using client: Authentication,
                           result: @escaping FlutterResult) {
        let handler = methodHandlers[.resetPassword] ?? AuthAPIResetPasswordMethodHandler(client: client)
        handler.handle(with: arguments, callback: result)
    }
}
