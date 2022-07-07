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

    init(from dictionary: [String: String]) {
        self.title = dictionary[LocalAuthenticationProperty.title] ?? "Please authenticate to continue"
        self.cancelTitle = dictionary[LocalAuthenticationProperty.cancelTitle]
        self.fallbackTitle = dictionary[LocalAuthenticationProperty.fallbackTitle]
    }
}
