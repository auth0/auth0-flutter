import Flutter

extension FlutterError {
    convenience init(from handlerError: HandlerError ) {
        self.init(code: handlerError.code, message: handlerError.message, details: nil)
    }
}
