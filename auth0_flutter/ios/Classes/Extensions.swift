import Auth0
import Flutter

extension Array where Element == String {
    var asSpaceSeparatedString: String {
        return self.joined(separator: " ")
    }
}

extension FlutterError {
    convenience init(from handlerError: HandlerError ) {
        self.init(code: handlerError.code, message: handlerError.message, details: nil)
    }
}

extension Auth0Error {
    var details: [String: Any]? {
        if let apiError = self as? Auth0APIError {
            var info = apiError.info
            if let cause = cause {
                info["cause"] = String(describing: cause)
            }
            return info
        }
        guard let cause = cause else { return nil }
        return ["cause": String(describing: cause)]
    }
}
