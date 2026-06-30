import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountEnrollEmailMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollEmailMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollEmailMethodHandler(client: client)
    }

    func testProducesErrorWhenEmailMissing() {
        let expectation = self.expectation(description: "Missing email")
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesEmailToSDK() {
        let expectation = self.expectation(description: "Email passed to SDK")
        sut.handle(with: ["email": "test@example.com"]) { _ in
            XCTAssertEqual(self.spy.enrollEmailArg, "test@example.com")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeOnSuccess() {
        let expectation = self.expectation(description: "Produced challenge")
        sut.handle(with: ["email": "test@example.com"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "email|test")
            XCTAssertEqual(dict["auth_session"] as? String, "session123")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollEmailResult = .failure(MyAccountError(info: [:], statusCode: 400))
        sut.handle(with: ["email": "test@example.com"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
