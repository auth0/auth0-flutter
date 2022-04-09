import Flutter
import Auth0

// MARK: - Extensions

extension MethodHandler {
    func result(from databaseUser: DatabaseUser) -> Any? {
        let data: [String: Any?] = [
            "email": databaseUser.email,
            "username": databaseUser.username,
            "verified": databaseUser.verified
        ]
        return data
    }

    func result(from userInfo: UserInfo) -> Any? {
        let data: [String: Any?] = [
            "sub": userInfo.sub,
            "name": userInfo.name,
            "givenName": userInfo.givenName,
            "familyName": userInfo.familyName,
            "middleName": userInfo.middleName,
            "nickname": userInfo.nickname,
            "preferredUsername": userInfo.preferredUsername,
            "profile": userInfo.profile,
            "picture": userInfo.picture,
            "website": userInfo.website,
            "email": userInfo.email,
            "emailVerified": userInfo.emailVerified,
            "gender": userInfo.gender,
            "birthdate": userInfo.birthdate,
            "zoneinfo": userInfo.zoneinfo,
            "locale": userInfo.locale,
            "phoneNumber": userInfo.phoneNumber,
            "phoneNumberVerified": userInfo.phoneNumberVerified,
            "address": userInfo.address,
            "updatedAt": userInfo.updatedAt,
            "customClaims": userInfo.customClaims
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
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let usernameOrEmail = arguments["usernameOrEmail"] as? String,
              let password = arguments["password"] as? String,
              let realmOrConnection = arguments["realmOrConnection"] as? String,
              let scopes = arguments["scopes"] as? [String],
              let parameters = arguments["parameters"] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
        }

        let audience = arguments["audience"] as? String

        client
            .login(usernameOrEmail: usernameOrEmail,
                   password: password,
                   realmOrConnection: realmOrConnection,
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
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments["email"] as? String,
              let password = arguments["password"] as? String,
              let connection = arguments["connection"] as? String,
              let parameters = arguments["parameters"] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
        }

        let username = arguments["username"] as? String
        let userMetadata = arguments["userMetadata"] as? [String: Any]

        client
            .signup(email: email,
                    username: username,
                    password: password,
                    connection: connection,
                    userMetadata: userMetadata)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(databaseUser): callback(result(from: databaseUser))
                case let .failure(error): callback(FlutterError(from: error))
                }

            }
    }
}

struct AuthAPIUserInfoMethodHandler: MethodHandler {
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let accessToken = arguments["accessToken"] as? String,
              let parameters = arguments["parameters"] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
        }

        client
            .userInfo(withAccessToken: accessToken)
            .parameters(parameters)
            .start {
                switch $0 {
                case let .success(userInfo): callback(result(from: userInfo))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}

struct AuthAPIRenewAccessTokenMethodHandler: MethodHandler {
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let refreshToken = arguments["refreshToken"] as? String,
              let scopes = arguments["scopes"] as? [String] else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
        }

        client
            .renew(withRefreshToken: refreshToken,
                   scope: scopes.isEmpty ? nil : scopes.asSpaceSeparatedString)
            .start {
                switch $0 {
                case let .success(credentials): callback(result(from: credentials))
                case let .failure(error): callback(FlutterError(from: error))
                }
            }
    }
}

struct AuthAPIResetPasswordMethodHandler: MethodHandler {
    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let email = arguments["email"] as? String,
              let connection = arguments["connection"] as? String,
              let parameters = arguments["parameters"] as? [String: String] else {
            return callback(FlutterError(from: .requiredArgumentsMissing))
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
    enum Method: String, RawRepresentable, CaseIterable {
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
        guard let arguments = call.arguments as? [String: Any],
              let clientId = arguments["clientId"] as? String,
              let domain = arguments["domain"] as? String else {
            return result(FlutterError(from: .requiredArgumentsMissing))
        }

        let client = Auth0.authentication(clientId: clientId, domain: domain)

        switch Method(rawValue: call.method) {
        case .loginWithUsernameOrEmail: callLoginWithUsernameOrEmail(with: arguments, using: client, result: result)
        case .signup: callSignup(with: arguments, using: client, result: result)
        case .userInfo: callUserInfo(with: arguments, using: client, result: result)
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

    func callUserInfo(with arguments: [String: Any], using client: Authentication, result: @escaping FlutterResult) {
        let handler = methodHandlers[.userInfo] ?? AuthAPIUserInfoMethodHandler(client: client)
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
