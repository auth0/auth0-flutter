import XCTest
import Auth0

@testable import auth0_flutter

class MyAccountUpdateAuthMethodMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountUpdateAuthMethodMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountUpdateAuthMethodMethodHandler(client: client)
    }

    func testProducesErrorWhenIdMissing() {
        let expectation = self.expectation(description: "Missing id")
        sut.handle(with: ["name": "New name"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesArgumentsToSDK() {
        let expectation = self.expectation(description: "Arguments passed to SDK")
        sut.handle(with: [
            "id": "test-id",
            "name": "My phone",
            "preferredAuthenticationMethod": "voice"
        ]) { _ in
            XCTAssertEqual(self.spy.updateIdArg, "test-id")
            XCTAssertEqual(self.spy.updateNameArg, "My phone")
            XCTAssertEqual(self.spy.updatePreferredArg, .voice)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesNilOptionalsWhenAbsent() {
        let expectation = self.expectation(description: "Nil optionals")
        sut.handle(with: ["id": "test-id"]) { _ in
            XCTAssertNil(self.spy.updateNameArg)
            XCTAssertNil(self.spy.updatePreferredArg)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesDictionaryOnSuccess() {
        let expectation = self.expectation(description: "Produced dictionary")
        sut.handle(with: ["id": "test-id", "name": "My phone"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "test-id")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.updateResult = .failure(MyAccountError(info: [:], statusCode: 404))
        sut.handle(with: ["id": "test-id"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
