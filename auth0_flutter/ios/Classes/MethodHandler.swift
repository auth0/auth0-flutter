import Flutter

protocol MethodHandler: Failable { 
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
}

extension MethodHandler { 
    func wrap(result: [String: Any?]?) -> [String: Any?] {
        return ["result": result]
    }
}
