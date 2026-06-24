import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountDeleteAuthMethodMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountDeleteAuthMethodMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountDeleteAuthMethodMethodHandler(client: client)
    }

    func testProducesErrorWhenIdMissing() {
        let expectation = self.expectation(description: "Missing id")
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesIdToSDK() {
        let expectation = self.expectation(description: "ID passed to SDK")
        sut.handle(with: ["id": "method-123"]) { _ in
            XCTAssertEqual(self.spy.deleteIdArg, "method-123")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesNilOnSuccess() {
        let expectation = self.expectation(description: "Produced nil")
        sut.handle(with: ["id": "method-123"]) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.deleteResult = .failure(MyAccountError(info: [:], statusCode: 404))
        sut.handle(with: ["id": "method-123"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
