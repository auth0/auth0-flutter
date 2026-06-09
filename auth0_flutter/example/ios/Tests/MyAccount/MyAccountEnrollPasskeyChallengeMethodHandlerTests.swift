#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class MyAccountEnrollPasskeyChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollPasskeyChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollPasskeyChallengeMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledEnrollPasskeyChallenge)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testForwardsUserIdentityIdAndConnection() {
        let expectation = self.expectation(description: "Forwarded arguments")
        sut.handle(with: ["userIdentityId": "uid", "connection": "db"]) { _ in
            XCTAssertEqual(self.spy.enrollPasskeyChallengeUserIdentityIdArg, "uid")
            XCTAssertEqual(self.spy.enrollPasskeyChallengeConnectionArg, "db")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeDictionary() {
        let expectation = self.expectation(description: "Produced passkey challenge")
        sut.handle(with: [:]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["authenticationMethodId"] as? String, "passkey|test")
            XCTAssertEqual(dict["authSession"] as? String, "session123")
            let publicKey = dict["authParamsPublicKey"] as? [String: Any]
            XCTAssertEqual(publicKey?["rpId"] as? String, "example.com")
            XCTAssertEqual(publicKey?["userName"] as? String, "john@example.com")
            XCTAssertNotNil(publicKey?["challenge"])
            XCTAssertNotNil(publicKey?["userId"])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPasskeyChallengeShouldFail = true
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
#endif
