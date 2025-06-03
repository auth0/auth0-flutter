import Foundation
import Auth0

protocol CredentialsManagerProtocol {
    func credentials(withScope scope: String?, minTTL: Int, parameters: [String: Any], headers: [String: String], callback: @escaping (CredentialsManagerResult<Credentials>) -> Void)
    func renew(parameters: [String: Any], headers: [String: String], callback: @escaping (CredentialsManagerResult<Credentials>) -> Void)
}

extension Auth0.CredentialsManager: CredentialsManagerProtocol {
}
enum LocalAuthenticationProperty: String, CaseIterable {
    case title
    case cancelTitle
    case fallbackTitle
}

struct LocalAuthentication {
    let title: String
    let cancelTitle: String?
    let fallbackTitle: String?

    static let key = "localAuthentication"

    init(from dictionary: [String: String?]) {
        self.title = dictionary[LocalAuthenticationProperty.title] as? String ?? "Please authenticate to continue"
        self.cancelTitle = dictionary[LocalAuthenticationProperty.cancelTitle] as? String
        self.fallbackTitle = dictionary[LocalAuthenticationProperty.fallbackTitle] as? String
    }
}
