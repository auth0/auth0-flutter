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
        sut.handle(with: ["authSession": "session", "factorType": "recovery-code"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthSessionMissing() {
        let expectation = self.expectation(description: "Missing authSession")
        sut.handle(with: ["id": "test-id", "factorType": "recovery-code"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenFactorTypeMissing() {
        let expectation = self.expectation(description: "Missing factorType")
        sut.handle(with: ["id": "test-id", "authSession": "session"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testRoutesToPushNotificationEnrollment() {
        let expectation = self.expectation(description: "Routes to push enrollment")
        sut.handle(with: ["id": "test-id", "authSession": "session", "factorType": "push-notification"]) { _ in
            XCTAssertEqual(self.spy.confirmEnrollmentFactorType, "push-notification")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testRoutesToRecoveryCodeEnrollment() {
        let expectation = self.expectation(description: "Routes to recovery-code enrollment")
        sut.handle(with: ["id": "test-id", "authSession": "session", "factorType": "recovery-code"]) { _ in
            XCTAssertEqual(self.spy.confirmEnrollmentFactorType, "recovery-code")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesDictionaryOnSuccess() {
        let expectation = self.expectation(description: "Produced dictionary")
        sut.handle(with: ["id": "test-id", "authSession": "session", "factorType": "recovery-code"]) { result in
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
        sut.handle(with: ["id": "test-id", "authSession": "session", "factorType": "recovery-code"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
