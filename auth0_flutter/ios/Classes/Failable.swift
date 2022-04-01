protocol Failable { 
    func failure(_ handlerError: HandlerError) -> [String: Any?]
}

extension Failable {
    func failure(code: String, message: String) -> [String: Any?] {
        let error: [String: Any] = ["code": code, "message": message]
        return wrap(error: error)
    }

    func failure(_ handlerError: HandlerError) -> [String: Any?] { 
        return failure(code: handlerError.code, message: handlerError.message)
    }

    func wrap(error: [String: Any]) -> [String: Any?] {
        return ["error": error]
    }
}
