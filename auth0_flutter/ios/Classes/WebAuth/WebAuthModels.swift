/*enum LocalAuthenticationProperty: String, CaseIterable {
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
}*/

enum SafariViewControllerProperty: String, CaseIterable {
    case presentationStyle
}

struct SafariViewController {
    var presentationStyle: UIModalPresentationStyle?
    
    static let key = "safariViewController";
    
    init(from dictionary: [String: Any?]) {
        if let presentationStyle = dictionary[SafariViewControllerProperty.presentationStyle] as? Int {
           self.presentationStyle = UIModalPresentationStyle.init(rawValue: presentationStyle)
        }
    }
}
