import Auth0

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
