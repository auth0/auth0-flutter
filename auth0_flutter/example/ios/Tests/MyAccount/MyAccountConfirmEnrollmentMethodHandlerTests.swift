import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountConfirmEnrollmentMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountConfirmEnrollmentMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountConfirmEnrollmentMethodHandler(client: client)
    }

    func testProducesErrorWhenIdMissing() {
        let expectation = self.expectation(description: "Missing id")
        sut.handle(with: ["authSession": "session"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthSessionMissing() {
        let expectation = self.expectation(description: "Missing authSession")
        sut.handle(with: ["id": "test-id"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesDictionaryOnSuccess() {
        let expectation = self.expectation(description: "Produced dictionary")
        sut.handle(with: ["id": "test-id", "authSession": "session"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "test-id")
            XCTAssertEqual(dict["confirmed"] as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.confirmResult = .failure(MyAccountError(info: [:], statusCode: 403))
        sut.handle(with: ["id": "test-id", "authSession": "session"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
