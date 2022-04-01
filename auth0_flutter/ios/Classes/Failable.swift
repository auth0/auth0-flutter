protocol Failable {
    func failure(code: String, message: String) -> [String: Any?]
}

extension Failable {
    func failure(code: String, message: String) -> [String: Any?] {
        let error: [String: Any] = ["code": code, "message": message]
        return self.wrap(error: error)
    }

    func wrap(error: [String: Any]) -> [String: Any?] {
        return ["error": error]
    }
}
