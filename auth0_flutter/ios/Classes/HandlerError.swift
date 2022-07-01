enum HandlerError: Error {
    case argumentsMissing
    case accountMissing
    case userAgentMissing
    case requiredArgumentMissing(String)
    case requiredArgumentsMissing([String])
    case idTokenDecodingFailed

    var code: String {
        switch self {
        case .argumentsMissing: return "SWIFT_ARGUMENTS_MISSING"
        case .accountMissing: return "SWIFT_ACCOUNT_MISSING"
        case .userAgentMissing: return "SWIFT_USER_AGENT_MISSING"
        case .requiredArgumentMissing: return "SWIFT_REQUIRED_ARGUMENT_MISSING"
        case .requiredArgumentsMissing: return "SWIFT_REQUIRED_ARGUMENTS_MISSING"
        case .idTokenDecodingFailed: return "SWIFT_ID_TOKEN_DECODING_FAILED"
        }
    }

    var message: String {
        switch self {
        case .argumentsMissing: return "The arguments dictionary is missing or has the wrong type."
        case .accountMissing: return "The account dictionary is missing or incomplete, or has the wrong type."
        case .userAgentMissing: return "The userAgent dictionary is missing or incomplete, or has the wrong type."
        case let .requiredArgumentMissing(argument):
            return "The required argument '\(argument)' is missing."
        case let .requiredArgumentsMissing(arguments):
            return "At least one of the following required arguments [\(arguments.asCommaSeparatedString)] is missing."
        case .idTokenDecodingFailed: return "Unable to decode the ID Token."
        }
    }
}
