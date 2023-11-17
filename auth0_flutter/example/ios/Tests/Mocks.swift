import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

let testIdToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
    + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vcGljdHVyZSIsInVwZGF0ZWRfYXQiOiIyMDI"
    + "yLTA0LTE1VDAzOjE1OjUxLjc4N1oifQ.mFq-johzLTFQUAl9pjgQraTM6I8AGfcEcWBg0Ah2vss"

// MARK: - Foundation Mocks

let mockURL = URL(string: "https://example.com")!
let mockURLSession = { () -> URLSession in
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses?.insert(MockURLProtocol.self, at: 0)
    return URLSession(configuration: configuration)
}()

class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return URLRequest(url: mockURL)
    }

    override func startLoading() {
        let response = HTTPURLResponse(url: mockURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - Auth0.swift Mocks

struct MockError: Error {}

struct MockAuth0Error: Auth0Error {
    var debugDescription: String
    var cause: Error?
}

struct MockAuth0APIError: Auth0APIError {
    var info: [String: Any]
    var code: String
    var statusCode: Int
    var debugDescription: String
    var cause: Error?

    init(info: [String: Any], statusCode: Int, cause: Error?) {
        self.info = info
        self.code = ""
        self.statusCode = statusCode
        self.debugDescription = ""
        self.cause = cause
    }

    init(info: [String: Any], statusCode: Int) {
        self.init(info: info, statusCode: statusCode, cause: nil)
    }
}

// MARK: - Flutter Mocks

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
    #if os(iOS)
    func messenger() -> FlutterBinaryMessenger {
        return MockBinaryMessenger()
    }

    func textures() -> FlutterTextureRegistry {
        return MockTextureRegistry()
    }

    func addApplicationDelegate(_ delegate: FlutterPlugin) {}

    func register(_ factory: FlutterPlatformViewFactory,
                  withId: String,
                  gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy) {}
    #else
    let messenger: FlutterBinaryMessenger = MockBinaryMessenger()

    let textures: FlutterTextureRegistry = MockTextureRegistry()

    func addApplicationDelegate(_ delegate: FlutterAppLifecycleDelegate) {}

    var view: NSView?
    #endif

    private(set) var delegate: FlutterPlugin?

    func register(_ factory: FlutterPlatformViewFactory, withId: String) {}

    func publish(_ value: NSObject) {}

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
