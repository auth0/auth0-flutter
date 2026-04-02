import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

struct AuthAPIPasswordlessLoginWithOtpMethodHandler: MethodHandler {
    enum Argument: String {
        case authSession
        case otp
        case scopes
        case audience
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let authSession = arguments[Argument.authSession] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.authSession.rawValue)))
        }
        guard let otp = arguments[Argument.otp] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.otp.rawValue)))
        }

        // `PasswordlessChallenge` has no public initializer, but it is `Codable`
        // with `authSession` mapped to the `auth_session` JSON key. Reconstruct
        // it by decoding the opaque session token.
        guard let challengeData = try? JSONSerialization.data(withJSONObject: ["auth_session": authSession]),
              let challenge = try? JSONDecoder().decode(PasswordlessChallenge.self, from: challengeData) else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.authSession.rawValue)))
        }

        let audience = arguments[Argument.audience] as? String
        let scopes = arguments[Argument.scopes] as? [String] ?? []

        // When no scopes are provided, let the native SDK apply its own default
        // scope (matching the Android handler) rather than hardcoding one here.
        let request = scopes.isEmpty
            ? client.login(otp: otp, challenge: challenge, audience: audience)
            : client.login(otp: otp,
                           challenge: challenge,
                           audience: audience,
                           scope: scopes.asSpaceSeparatedString)

        request.start {
            switch $0 {
            case let .success(credentials): callback(result(from: credentials))
            case let .failure(error): callback(FlutterError(from: error))
            }
        }
    }
}
