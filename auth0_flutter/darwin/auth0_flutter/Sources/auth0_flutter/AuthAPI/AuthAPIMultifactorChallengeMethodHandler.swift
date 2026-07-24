import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

enum ChallengeProperty: String {
    case challengeType
    case oobCode
    case bindingMethod
}

fileprivate extension MethodHandler {
    func result(from challenge: MFAChallenge) -> Any? {
        var data: [String: Any] = [ChallengeProperty.challengeType.rawValue: challenge.challengeType]
        data[ChallengeProperty.oobCode] = challenge.oobCode
        data[ChallengeProperty.bindingMethod] = challenge.bindingMethod
        return data
    }
}

// `Authentication.multifactorChallenge(mfaToken:types:authenticatorId:)` was removed in
// Auth0.swift v3. Use the dedicated `MFAClient` instead (see Auth0.swift's
// V3_MIGRATION_GUIDE.md). Note that `MFAClient.challenge(with:mfaToken:)` only accepts an
// `authenticatorId` and always challenges using the "oob" challenge type on the server; the
// previously supported `types` parameter has no equivalent in the new API and is no longer
// forwarded.
struct AuthAPIMultifactorChallengeMethodHandler: MethodHandler {
    enum Argument: String {
        case mfaToken
        case types
        case authenticatorId
    }

    let client: MFAClient

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let mfaToken = arguments[Argument.mfaToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.mfaToken.rawValue)))
        }
        guard let authenticatorId = arguments[Argument.authenticatorId] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.authenticatorId.rawValue)))
        }

        client
            .challenge(with: authenticatorId, mfaToken: mfaToken)
            .start {
                switch $0 {
                case let .success(challenge): callback(result(from: challenge))
                case let .failure(error): callback(FlutterError(from: error))
                }

            }
    }
}
