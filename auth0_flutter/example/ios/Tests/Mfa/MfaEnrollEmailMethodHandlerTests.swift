import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MfaEnrollEmailMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaEnrollEmailMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaEnrollEmailMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: ["email": "user@example.com"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenEmailMissing() {
        let expectation = self.expectation(description: "Missing email")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesEmailToSDK() {
        let expectation = self.expectation(description: "Email passed to SDK")
        sut.handle(with: ["mfaToken": "mfa-token", "email": "user@example.com"]) { _ in
            XCTAssertTrue(self.spy.calledEnrollEmail)
            XCTAssertEqual(self.spy.enrollEmailArg, "user@example.com")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeOnSuccess() {
        let expectation = self.expectation(description: "Produced challenge")
        sut.handle(with: ["mfaToken": "mfa-token", "email": "user@example.com"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["authenticator_type"] as? String, "oob")
            XCTAssertEqual(dict["oob_channel"] as? String, "email")
            XCTAssertEqual(dict["oob_code"] as? String, "oob-code")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollEmailResult = .failure(MfaEnrollmentError(info: [:], statusCode: 400))
        sut.handle(with: ["mfaToken": "mfa-token", "email": "user@example.com"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
