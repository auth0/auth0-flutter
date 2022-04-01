protocol ErrorResulting {
    func errorResult(with error: [String: Any]) -> [String: Any?]
}

extension ErrorResulting {
    func errorResult(with error: [String: Any]) -> [String: Any?] {
        return ["error": error]
    }

    func errorResult(_ handlerError: HandlerError) -> [String: Any?] {
        return errorResult(with: ["code": handlerError.code, "message": handlerError.code])
    }
}
