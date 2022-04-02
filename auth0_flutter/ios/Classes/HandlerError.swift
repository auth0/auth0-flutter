enum HandlerError: String {
    case requiredArgumentsMissing = "REQUIRED_ARGUMENTS_MISSING"
    case idTokenDecodingFailed = "ID_TOKEN_DECODING_FAILED"

    var code: String { 
        return rawValue
    }

    var message: String {
        switch self {
        case .requiredArgumentsMissing: return "One or more required arguments are missing."
        case .idTokenDecodingFailed: return "Unable to decode the ID Token."
        }
    }
}
