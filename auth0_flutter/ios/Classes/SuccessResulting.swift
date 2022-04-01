protocol SuccessResulting {
    func successResult(with result: [String: Any?]?) -> [String: Any?]
}

extension SuccessResulting {
    func successResult(with result: [String: Any?]?) -> [String: Any?] {
        return ["success": result]
    }

    func successResult() -> [String: Any?] {
        return successResult(with: nil)
    }
}
