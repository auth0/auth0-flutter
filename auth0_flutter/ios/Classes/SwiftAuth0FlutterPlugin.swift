import Flutter

public class SwiftAuth0FlutterPlugin: NSObject {
    static var webAuthHandler: FlutterPlugin.Type?
    static var authenticationAPIHandler: FlutterPlugin.Type?

    public static func register(with registrar: FlutterPluginRegistrar) {
        (webAuthHandler ?? WebAuthHandler.self).register(with: registrar)
        (authenticationAPIHandler ?? AuthenticationAPIHandler.self).register(with: registrar)
    }
}

extension SwiftAuth0FlutterPlugin: FlutterPlugin {}
