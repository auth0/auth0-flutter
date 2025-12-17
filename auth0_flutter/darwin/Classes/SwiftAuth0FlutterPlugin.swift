#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

public class SwiftAuth0FlutterPlugin: NSObject, FlutterPlugin {
    static var handlers: [FlutterPlugin.Type] = [WebAuthHandler.self,
                                                 AuthAPIHandler.self,
                                                 DPoPHandler.self,
                                                 CredentialsManagerHandler.self]

    public static func register(with registrar: FlutterPluginRegistrar) {
        handlers.forEach { $0.register(with: registrar) }
    }
}
