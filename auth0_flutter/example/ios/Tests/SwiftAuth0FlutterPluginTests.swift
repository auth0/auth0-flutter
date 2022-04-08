import XCTest

@testable import auth0_flutter

class SwiftAuth0FlutterPluginTests: XCTestCase {
    let sut = SwiftAuth0FlutterPlugin.self

    override func setUpWithError() throws {
        SwiftAuth0FlutterPlugin.handlers = []
        SpyFlutterPlugin.calledRegister = false
    }
}

// MARK: - Handler Registration

extension SwiftAuth0FlutterPluginTests {
    func testRegistersWebAuthHandler() {
        sut.handlers = [SpyFlutterPlugin.self]
        sut.register(with: SpyPluginRegistrar())
        XCTAssertTrue(SpyFlutterPlugin.calledRegister)
    }

    func testRegistersAuthenticationAPIHandler() {
        sut.handlers = [SpyFlutterPlugin.self]
        sut.register(with: SpyPluginRegistrar())
        XCTAssertTrue(SpyFlutterPlugin.calledRegister)
    }
}
