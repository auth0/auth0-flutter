import XCTest
@testable import Auth0

@testable import auth0_flutter

class MfaGetAuthenticatorsMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaGetAuthenticatorsMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaGetAuthenticatorsMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesMfaTokenAndFactorsToSDK() {
        let expectation = self.expectation(description: "Args passed to SDK")

        sut.handle(with: ["mfaToken": "mfa-token", "factorsAllowed": ["totp", "phone"]]) { _ in
            XCTAssertTrue(self.spy.calledGetAuthenticators)
            XCTAssertEqual(self.spy.getAuthenticatorsMfaTokenArg, "mfa-token")
            XCTAssertEqual(self.spy.getAuthenticatorsFactorsArg, ["totp", "phone"])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testDefaultsToEmptyFactorsWhenMissing() {
        let expectation = self.expectation(description: "Empty factors default")
        sut.handle(with: ["mfaToken": "mfa-token"]) { _ in
            XCTAssertEqual(self.spy.getAuthenticatorsFactorsArg, [])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticatorListOnSuccess() {
        let expectation = self.expectation(description: "Produced list")
        spy.getAuthenticatorsResult = .success([
            Authenticator(authenticatorType: "oob", oobChannel: "sms", id: "sms|dev_1",
                          name: "+1******90", active: true, type: "sms")
        ])
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            guard let list = result as? [[String: Any?]] else {
                return XCTFail("Did not produce a list")
            }
            XCTAssertEqual(list.count, 1)
            XCTAssertEqual(list.first?["id"] as? String, "sms|dev_1")
            XCTAssertEqual(list.first?["oob_channel"] as? String, "sms")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.getAuthenticatorsResult = .failure(MfaListAuthenticatorsError(info: [:], statusCode: 401))
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
