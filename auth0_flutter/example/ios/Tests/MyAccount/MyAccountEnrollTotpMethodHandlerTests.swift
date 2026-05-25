import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountEnrollTotpMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollTotpMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollTotpMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledEnrollTOTP)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeWithTotpFields() {
        let expectation = self.expectation(description: "Produced TOTP challenge")
        sut.handle(with: [:]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "totp|test")
            XCTAssertEqual(dict["auth_session"] as? String, "session123")
            XCTAssertEqual(dict["totp_secret"] as? String, "SECRET123")
            XCTAssertEqual(dict["totp_uri"] as? String, "otpauth://totp/test")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollTOTPResult = .failure(MyAccountError(info: [:], statusCode: 401))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
