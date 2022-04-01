import Flutter

enum HandlerError: String {
    case missingRequiredArguments = "MISSING_REQUIRED_ARGUMENTS"
    case idTokenDecodingFailed = "ID_TOKEN_DECODING_FAILED"

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
