import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountEnrollPhoneMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollPhoneMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollPhoneMethodHandler(client: client)
    }

    func testProducesErrorWhenPhoneNumberMissing() {
        let expectation = self.expectation(description: "Missing phoneNumber")
        sut.handle(with: ["type": "sms"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenTypeMissing() {
        let expectation = self.expectation(description: "Missing type")
        sut.handle(with: ["phoneNumber": "+1234567890"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesPhoneNumberToSDK() {
        let expectation = self.expectation(description: "Phone passed to SDK")
        sut.handle(with: ["phoneNumber": "+1234567890", "type": "sms"]) { _ in
            XCTAssertEqual(self.spy.enrollPhoneNumberArg, "+1234567890")
            XCTAssertEqual(self.spy.enrollPhoneMethodArg, .sms)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesVoiceTypeToSDK() {
        let expectation = self.expectation(description: "Voice type passed to SDK")
        sut.handle(with: ["phoneNumber": "+1234567890", "type": "voice"]) { _ in
            XCTAssertEqual(self.spy.enrollPhoneMethodArg, .voice)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeOnSuccess() {
        let expectation = self.expectation(description: "Produced challenge")
        sut.handle(with: ["phoneNumber": "+1234567890", "type": "sms"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "phone|test")
            XCTAssertEqual(dict["auth_session"] as? String, "session123")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPhoneResult = .failure(MyAccountError(info: [:], statusCode: 400))
        sut.handle(with: ["phoneNumber": "+1234567890", "type": "sms"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
