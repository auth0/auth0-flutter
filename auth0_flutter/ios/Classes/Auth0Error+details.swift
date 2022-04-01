import Auth0

extension Auth0Error {
   var details: [String: Any]? {
       guard let cause = cause else { return nil }
       var causeDetails: [String: Any] = ["message": String(describing: cause)]
       if let apiError = cause as? Auth0APIError {
           causeDetails["info"] = apiError.info
       }
       return ["cause": causeDetails]
    }
}
