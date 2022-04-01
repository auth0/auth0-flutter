import Flutter

protocol MethodHandler {
    func handle(with arguments: [String: Any], callback: @escaping FlutterResult)
    func failure(code: String, message: String) -> [String: Any?]
}
