import XCTest
import Auth0

@testable import auth0_flutter

class WebAuthLogoutHandlerTests: XCTestCase {
    var spy: SpyWebAuth!
    var sut: WebAuthLogoutMethodHandler!

    override func setUpWithError() throws {
        spy = SpyWebAuth()
        sut = WebAuthLogoutMethodHandler(client: spy)
    }
}

// MARK: - Arguments

extension WebAuthLogoutHandlerTests {

    // MARK: returnTo

    func testAddsReturnTo() {
        let value = "https://auth0.com"
        sut.handle(with: [WebAuthLogoutMethodHandler.Argument.returnTo.rawValue: value]) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, value)
    }

    func testDoesNotAddReturnToWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }
}

// MARK: - Logout Result

extension WebAuthLogoutHandlerTests {
    func testCallsSDKLogoutMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLogout)
    }

    func testProducesNilValue() {
        let expectation = self.expectation(description: "Produced nil value")
        spy.logoutResult = .success(())
        sut.handle(with: arguments()) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesWebAuthError() {
        let error = WebAuthError.userCancelled
        let expectation = self.expectation(description: "Produced a WebAuthError")
        spy.logoutResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
