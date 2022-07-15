import Flutter
import Auth0
import SimpleKeychain

struct CredentialsManagerHasValidMethodHandler: MethodHandler {
    enum Argument: String {
        case minTtl
    }

    let credentialsManager: CredentialsManager
    let credentialsStorage: CredentialsStorage
    let credentialsKey = "credentials"

    init(credentialsManager: CredentialsManager, credentialsStorage: CredentialsStorage = A0SimpleKeychain()) {
        self.credentialsManager = credentialsManager
        self.credentialsStorage = credentialsStorage
    }

    func handle(with arguments: [String: Any], callback: @escaping FlutterResult) {
        guard let minTTL = arguments[Argument.minTtl] as? Int else {
            return callback(FlutterError(from: .requiredArgumentMissing(Argument.minTtl.rawValue)))
        }

        // So it behaves the same as the Credentials Manager from Auth0.Android
        if let data = self.credentialsStorage.getEntry(forKey: credentialsKey),
           let credentials = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Credentials.self, from: data),
           credentials.refreshToken != nil {
            return callback(true)
        }

        callback(credentialsManager.hasValid(minTTL: minTTL))
    }
}
