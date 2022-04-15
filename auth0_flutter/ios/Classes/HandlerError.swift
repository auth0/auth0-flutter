enum HandlerError {
    case argumentsMissing
    case requiredArgumentMissing(String)
    case idTokenDecodingFailed

    var code: String { 
        switch self {
        case .argumentsMissing: return "SWIFT_ARGUMENTS_MISSING"
        case .requiredArgumentMissing: return "SWIFT_REQUIRED_ARGUMENT_MISSING"
        case .idTokenDecodingFailed: return "SWIFT_ID_TOKEN_DECODING_FAILED"
        }
    }

    var message: String {
        switch self {
        case .argumentsMissing: return "The arguments dictionary is missing or has the wrong type."
        case let .requiredArgumentMissing(argument):
            return "The required argument '\(argument)' is missing or has the wrong type."
        case .idTokenDecodingFailed: return "Unable to decode the ID Token."
        }
    }
}
