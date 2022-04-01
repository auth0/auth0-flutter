protocol Failable { 
    func failure(_ handlerError: HandlerError) -> [String: Any?]
}

extension Failable { 
    func failure(_ handlerError: HandlerError) -> [String: Any?] { 
        return wrap(error: ["code": handlerError.code, "message": handlerError.code])
    }

    func wrap(error: [String: Any]) -> [String: Any?] {
        return ["error": error]
    }
}
