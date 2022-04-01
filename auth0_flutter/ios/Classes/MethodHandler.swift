import Flutter

protocol MethodHandler {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
    func failure(code: String, message: String) -> [String: Any?]
}

extension MethodHandler {
    func failure(code: String, message: String) -> [String: Any?] {
        let error: [String: Any] = ["code": code, "message": message]
        return self.wrap(error: error)
    }

    func wrap(error: [String: Any]) -> [String: Any?] {
        return ["error": error]
    }

    func wrap(result: [String: Any?]?) -> [String: Any?] {
        return ["result": result]
    }
}
