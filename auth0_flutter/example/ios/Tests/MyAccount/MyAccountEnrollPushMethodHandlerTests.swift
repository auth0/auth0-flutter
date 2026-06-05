import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountEnrollPushMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollPushMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollPushMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledEnrollPush)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeWithBarcodeUri() {
        let expectation = self.expectation(description: "Produced push challenge")
        sut.handle(with: [:]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "push|test")
            XCTAssertEqual(dict["auth_session"] as? String, "session123")
            XCTAssertEqual(dict["barcode_uri"] as? String, "otpauth://push/test")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPushResult = .failure(MyAccountError(info: [:], statusCode: 401))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
