import Flutter

enum HandlerError: String {
    case missingRequiredArguments
    case idTokenDecodingFailed

    var code: String { 
        return rawValue
    }

    var message: String {
        switch self {
        case .missingRequiredArguments: return "One or more required arguments are missing."
        case .idTokenDecodingFailed: return "Unable to decode the ID Token."
        }
    }
}
