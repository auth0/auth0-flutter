enum SafariViewControllerProperty: String, CaseIterable {
    case presentationStyle
}

struct SafariViewController {
    var presentationStyle: UIModalPresentationStyle = UIModalPresentationStyle.fullScreen
    
    static let key = "safariViewController";
    
    init(from dictionary: [String: Any?]) {
        if let presentationStyle = dictionary[SafariViewControllerProperty.presentationStyle] as? Int,
            let uiModelPresentationStyle = UIModalPresentationStyle(rawValue: presentationStyle) {
            self.presentationStyle = uiModelPresentationStyle
        }
    }
}
