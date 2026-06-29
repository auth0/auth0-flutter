import XCTest
import Auth0

@testable import auth0_flutter

class MfaChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaChallengeMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: ["authenticatorId": "sms|dev_1"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthenticatorIdMissing() {
        let expectation = self.expectation(description: "Missing authenticatorId")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesAuthenticatorIdToSDK() {
        let expectation = self.expectation(description: "Authenticator id passed to SDK")
        sut.handle(with: ["mfaToken": "mfa-token", "authenticatorId": "sms|dev_1"]) { _ in
            XCTAssertTrue(self.spy.calledChallenge)
            XCTAssertEqual(self.spy.challengeAuthenticatorIdArg, "sms|dev_1")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeOnSuccess() {
        let expectation = self.expectation(description: "Produced challenge")
        sut.handle(with: ["mfaToken": "mfa-token", "authenticatorId": "sms|dev_1"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["challenge_type"] as? String, "oob")
            XCTAssertEqual(dict["oob_code"] as? String, "oob-code")
            XCTAssertEqual(dict["binding_method"] as? String, "prompt")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.challengeResult = .failure(MfaChallengeError(info: [:], statusCode: 400))
        sut.handle(with: ["mfaToken": "mfa-token", "authenticatorId": "sms|dev_1"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
