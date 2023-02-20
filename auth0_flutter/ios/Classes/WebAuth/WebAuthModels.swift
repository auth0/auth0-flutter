enum SafariViewControllerProperty: String, CaseIterable {
    case presentationStyle
}

struct SafariViewController {
    var presentationStyle: UIModalPresentationStyle?
    
    static let key = "safariViewController";
    
    init(from dictionary: [String: Any?]) {
        if let presentationStyle = dictionary[SafariViewControllerProperty.presentationStyle] as? Int {
           self.presentationStyle = UIModalPresentationStyle(rawValue: presentationStyle)
        }
    }
}
