import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountGetFactorsMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountGetFactorsMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountGetFactorsMethodHandler(client: client)
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledGetFactors)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesEmptyArrayWhenNoFactors() {
        let expectation = self.expectation(description: "Produced empty array")
        spy.getFactorsResult = .success([])
        sut.handle(with: [:]) { result in
            guard let factors = result as? [[String: Any]] else {
                return XCTFail("Did not produce array")
            }
            XCTAssertEqual(factors.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.getFactorsResult = .failure(MyAccountError(info: [:], statusCode: 403))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
