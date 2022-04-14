import Flutter
import Auth0

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
        self.code = "foo"
        self.statusCode = statusCode
        self.debugDescription = "bar"
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
