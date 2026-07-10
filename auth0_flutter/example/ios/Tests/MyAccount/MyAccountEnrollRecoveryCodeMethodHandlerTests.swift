import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountEnrollRecoveryCodeMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollRecoveryCodeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollRecoveryCodeMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledEnrollRecovery)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeWithRecoveryCode() {
        let expectation = self.expectation(description: "Produced recovery challenge")
        sut.handle(with: [:]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "recovery|test")
            XCTAssertEqual(dict["auth_session"] as? String, "session123")
            XCTAssertEqual(dict["recovery_code"] as? String, "RECOVERY123")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollRecoveryResult = .failure(MyAccountError(info: [:], statusCode: 401))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
