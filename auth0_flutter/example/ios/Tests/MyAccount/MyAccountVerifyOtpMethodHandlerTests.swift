import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountVerifyOtpMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountVerifyOtpMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountVerifyOtpMethodHandler(client: client)
    }

    func testProducesErrorWhenIdMissing() {
        let expectation = self.expectation(description: "Missing id")
        sut.handle(with: ["authSession": "session", "otp": "123456"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthSessionMissing() {
        let expectation = self.expectation(description: "Missing authSession")
        sut.handle(with: ["id": "test-id", "otp": "123456"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenOtpMissing() {
        let expectation = self.expectation(description: "Missing otp")
        sut.handle(with: ["id": "test-id", "authSession": "session"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesArgumentsToSDK() {
        let expectation = self.expectation(description: "Arguments passed to SDK")
        sut.handle(with: ["id": "test-id", "authSession": "session123", "otp": "654321"]) { _ in
            XCTAssertEqual(self.spy.confirmIdArg, "test-id")
            XCTAssertEqual(self.spy.confirmAuthSessionArg, "session123")
            XCTAssertEqual(self.spy.confirmOtpArg, "654321")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesNilOnSuccess() {
        let expectation = self.expectation(description: "Produced nil")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456"]) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.confirmResult = .failure(MyAccountError(info: [:], statusCode: 403))
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "wrong"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
