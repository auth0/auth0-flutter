import Flutter

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {
    static var handlers: [FlutterPlugin.Type] = [WebAuthHandler.self, AuthAPIHandler.self]

    public static func register(with registrar: FlutterPluginRegistrar) {
        handlers.forEach { $0.register(with: registrar) }
    }
}
