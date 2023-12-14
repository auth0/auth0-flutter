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
    func result(from challenge: Challenge) -> Any? {
        var data: [String: Any] = [ChallengeProperty.challengeType.rawValue: challenge.challengeType]
        data[ChallengeProperty.oobCode] = challenge.oobCode
        data[ChallengeProperty.bindingMethod] = challenge.bindingMethod
        return data
    }
}

struct AuthAPIMultifactorChallengeMethodHandler: MethodHandler {
    enum Argument: String {
        case mfaToken
        case types
        case authenticatorId
    }

    let client: Authentication

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let mfaToken = arguments[Argument.mfaToken] as? String else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.mfaToken.rawValue)))
        }

        let types = arguments[Argument.types] as? [String]
        let authenticatorId = arguments[Argument.authenticatorId] as? String

        client
            .multifactorChallenge(mfaToken: mfaToken, types: types, authenticatorId: authenticatorId)
            .start {
                switch $0 {
                case let .success(challenge): callback(result(from: challenge))
                case let .failure(error): callback(FlutterError(from: error))
                }

            }
    }
}
