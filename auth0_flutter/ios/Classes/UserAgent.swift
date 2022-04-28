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
