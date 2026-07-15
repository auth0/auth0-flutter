import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountGetAuthMethodsMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountGetAuthMethodsMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountGetAuthMethodsMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledGetAuthMethods)
            XCTAssertNil(self.spy.getAuthMethodsTypeArg)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesTypeFilterToSDK() {
        let expectation = self.expectation(description: "Type filter passed to SDK")
        sut.handle(with: ["type": "push-notification"]) { _ in
            XCTAssertEqual(self.spy.getAuthMethodsTypeArg, .pushNotification)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesEmptyArrayWhenNoMethods() {
        let expectation = self.expectation(description: "Produced empty array")
        spy.getAuthMethodsResult = .success([])
        sut.handle(with: [:]) { result in
            guard let methods = result as? [[String: Any?]] else {
                return XCTFail("Did not produce array")
            }
            XCTAssertEqual(methods.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.getAuthMethodsResult = .failure(MyAccountError(info: [:], statusCode: 401))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
