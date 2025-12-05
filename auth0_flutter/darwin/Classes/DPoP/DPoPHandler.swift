import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

// MARK: - DPoP Handler

public class DPoPHandler: NSObject, FlutterPlugin {
    enum Method: String, CaseIterable {
        case getDPoPHeaders = "auth#getDPoPHeaders"
        case clearDPoPKey = "auth#clearDPoPKey"
    }

    private static let channelName = "auth0.com/auth0_flutter/dpop"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let handler = DPoPHandler()

        #if os(iOS)
        let channel = FlutterMethodChannel(name: DPoPHandler.channelName,
                                           binaryMessenger: registrar.messenger())
        #else
        let channel = FlutterMethodChannel(name: DPoPHandler.channelName,
                                           binaryMessenger: registrar.messenger)
        #endif

        registrar.addMethodCallDelegate(handler, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            return result(FlutterError(from: .argumentsMissing))
        }
        guard let method = Method(rawValue: call.method) else {
            return result(FlutterMethodNotImplemented)
        }

        let methodHandler: MethodHandler
        switch method {
        case .getDPoPHeaders:
            methodHandler = DPoPGetHeadersMethodHandler()
        case .clearDPoPKey:
            methodHandler = DPoPClearKeyMethodHandler()
        }

        methodHandler.handle(with: arguments, callback: result)
    }
}
