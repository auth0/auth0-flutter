import XCTest
import Auth0

@testable import auth0_flutter

class MfaEnrollPushMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaEnrollPushMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaEnrollPushMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testCallsEnrollPush() {
        let expectation = self.expectation(description: "Called enroll Push")
        sut.handle(with: ["mfaToken": "mfa-token"]) { _ in
            XCTAssertTrue(self.spy.calledEnrollPush)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeWithBarcodeOnSuccess() {
        let expectation = self.expectation(description: "Produced push challenge")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["authenticator_type"] as? String, "oob")
            XCTAssertEqual(dict["oob_channel"] as? String, "auth0")
            XCTAssertEqual(dict["oob_code"] as? String, "oob-code")
            XCTAssertEqual(dict["barcode_uri"] as? String, "otpauth://push/test")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPushResult = .failure(MfaEnrollmentError(info: [:], statusCode: 400))
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
