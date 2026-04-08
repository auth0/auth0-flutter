import XCTest

@testable import auth0_flutter

class Auth0FlutterPluginTests: XCTestCase {
    let sut = Auth0FlutterPlugin.self

    override func setUpWithError() throws {
        SpyFlutterPlugin.calledRegister = false
    }
}

// MARK: - Handler Registration

extension Auth0FlutterPluginTests {
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
