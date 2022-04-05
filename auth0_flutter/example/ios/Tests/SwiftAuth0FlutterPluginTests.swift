import XCTest
import Flutter

@testable import auth0_flutter

class SwiftAuth0FlutterPluginTests: XCTestCase {
    let sut = SwiftAuth0FlutterPlugin.self

    override func setUpWithError() throws {
        SpyFlutterPlugin.calledRegister = false
    }
}

// MARK: - Handler Registration

extension SwiftAuth0FlutterPluginTests {
    func testRegistersWebAuthHandler() {
        sut.webAuthHandler = SpyFlutterPlugin.self
        sut.register(with: SpyPluginRegistrar())
        XCTAssertTrue(SpyFlutterPlugin.calledRegister)
    }

    func testRegistersAuthenticationAPIHandler() {
        sut.authenticationAPIHandler = SpyFlutterPlugin.self
        sut.register(with: SpyPluginRegistrar())
        XCTAssertTrue(SpyFlutterPlugin.calledRegister)
    }
}
