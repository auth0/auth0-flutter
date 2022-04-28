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
