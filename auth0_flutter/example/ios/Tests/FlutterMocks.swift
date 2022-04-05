import Flutter

class SpyFlutterPlugin: NSObject, FlutterPlugin {
    static var calledRegister = false

    static func register(with registrar: FlutterPluginRegistrar) {
        calledRegister = true
    }
}

class MockBinaryMessenger: NSObject, FlutterBinaryMessenger {
    func send(onChannel channel: String, message: Data?) {}

    func send(onChannel channel: String, message: Data?, binaryReply: FlutterBinaryReply?) {}

    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler: FlutterBinaryMessageHandler?) ->
                                    FlutterBinaryMessengerConnection {
        return 0
    }

    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

class MockTextureRegistry: NSObject, FlutterTextureRegistry {
    func register(_ texture: FlutterTexture) -> Int64 {
        return 0
    }

    func textureFrameAvailable(_ textureId: Int64) {}

    func unregisterTexture(_ textureId: Int64) {}
}

class SpyPluginRegistrar: NSObject, FlutterPluginRegistrar {
    private(set) var delegate: FlutterPlugin?

    func messenger() -> FlutterBinaryMessenger {
        return MockBinaryMessenger()
    }

    func textures() -> FlutterTextureRegistry {
        return MockTextureRegistry()
    }

    func register(_ factory: FlutterPlatformViewFactory, withId: String) {}

    func register(_ factory: FlutterPlatformViewFactory,
                  withId: String,
                  gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy) {}

    func publish(_ value: NSObject) {}

    func addApplicationDelegate(_ delegate: FlutterPlugin) {}

    func lookupKey(forAsset asset: String) -> String {
        return ""
    }

    func lookupKey(forAsset: String, fromPackage: String) -> String {
        return ""
    }

    func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {
        self.delegate = delegate
    }
}
