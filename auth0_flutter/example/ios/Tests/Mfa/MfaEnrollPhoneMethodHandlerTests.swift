import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MfaEnrollPhoneMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaEnrollPhoneMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaEnrollPhoneMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: ["phoneNumber": "+1234567890"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenPhoneNumberMissing() {
        let expectation = self.expectation(description: "Missing phoneNumber")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesPhoneNumberToSDK() {
        let expectation = self.expectation(description: "Phone passed to SDK")
        sut.handle(with: ["mfaToken": "mfa-token", "phoneNumber": "+1234567890"]) { _ in
            XCTAssertTrue(self.spy.calledEnrollPhone)
            XCTAssertEqual(self.spy.enrollPhoneNumberArg, "+1234567890")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeOnSuccess() {
        let expectation = self.expectation(description: "Produced challenge")
        sut.handle(with: ["mfaToken": "mfa-token", "phoneNumber": "+1234567890"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["authenticator_type"] as? String, "oob")
            XCTAssertEqual(dict["oob_channel"] as? String, "sms")
            XCTAssertEqual(dict["oob_code"] as? String, "oob-code")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPhoneResult = .failure(MfaEnrollmentError(info: [:], statusCode: 400))
        sut.handle(with: ["mfaToken": "mfa-token", "phoneNumber": "+1234567890"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
