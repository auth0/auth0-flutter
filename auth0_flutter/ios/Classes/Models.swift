enum AccountProperty: String {
    case clientId
    case domain
}

struct Account {
    let clientId: String
    let domain: String

    static let key = "_account"

    init?(from dictionary: [String: String]) {
        guard let clientId = dictionary[AccountProperty.clientId],
              let domain = dictionary[AccountProperty.domain] else {
            return nil
        }

        self.clientId = clientId
        self.domain = domain
    }
}

enum UserAgentProperty: String {
    case name
    case version
}

struct UserAgent {
    let name: String
    let version: String

    static let key = "_userAgent"

    init?(from dictionary: [String: String]) {
        guard let name = dictionary[UserAgentProperty.name], let version = dictionary[UserAgentProperty.version] else {
            return nil
        }

        self.name = name
        self.version = version
    }
}
