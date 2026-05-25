import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountGetAuthMethodMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountGetAuthMethodMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountGetAuthMethodMethodHandler(client: client)
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
            XCTAssertEqual(self.spy.getAuthMethodIdArg, "method-123")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesMethodDictionaryOnSuccess() {
        let expectation = self.expectation(description: "Produced method")
        sut.handle(with: ["id": "method-123"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "test-id")
            XCTAssertEqual(dict["type"] as? String, "phone")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.getAuthMethodResult = .failure(MyAccountError(info: [:], statusCode: 404))
        sut.handle(with: ["id": "method-123"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
