import Auth0

struct MockError: Error {}

struct MockAuth0Error: Auth0Error {
    var debugDescription: String
    var cause: Error?
}

struct MockAuth0APIError: Auth0APIError {
    var info: [String: Any]
    var code: String
    var statusCode: Int
    var debugDescription: String
    var cause: Error?

    init(info: [String: Any], statusCode: Int, cause: Error?) {
        self.info = info
        self.code = "foo"
        self.statusCode = statusCode
        self.debugDescription = "bar"
        self.cause = cause
    }

    init(info: [String: Any], statusCode: Int) {
        self.init(info: info, statusCode: statusCode, cause: nil)
    }
}
