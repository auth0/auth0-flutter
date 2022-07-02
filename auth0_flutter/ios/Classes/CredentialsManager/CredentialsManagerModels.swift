protocol Requireable {
    var isRequired: Bool { get }
}

enum LocalAuthenticationProperty: String, CaseIterable, Requireable {
    case title
    case cancelTitle
    case fallbackTitle

    var isRequired: Bool {
        switch self {
        case .title: return true
        default: return false
        }
    }
}

struct LocalAuthentication {
    let title: String
    let cancelTitle: String?
    let fallbackTitle: String?

    static let key = "localAuthentication"
    static let requiredProperties = LocalAuthenticationProperty.allCases.filter({ $0.isRequired }).map(\.rawValue)

    init?(from dictionary: [String: String]) {
        guard let title = dictionary[LocalAuthenticationProperty.title] else { return nil }
        self.title = title
        self.cancelTitle = dictionary[LocalAuthenticationProperty.cancelTitle]
        self.fallbackTitle = dictionary[LocalAuthenticationProperty.fallbackTitle]
    }
}
