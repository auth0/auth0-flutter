import Flutter

public class SwiftAuth0FlutterPlugin: NSObject { 

  private let methodCallHandlers: [FlutterPlugin] = [WebAuthHandler(), AuthenticationAPIHandler()]

  public static func register(with registrar: FlutterPluginRegistrar) {
    WebAuthHandler.register(with: registrar)
    AuthenticationAPIHandler.register(with: registrar)
  }

}

extension SwiftAuth0FlutterPlugin: FlutterPlugin {}
