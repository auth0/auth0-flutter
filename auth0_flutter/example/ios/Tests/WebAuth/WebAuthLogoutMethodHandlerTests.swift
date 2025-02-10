import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = WebAuthLogoutMethodHandler.Argument

class WebAuthLogoutHandlerTests: XCTestCase {
    var spy: SpyWebAuth!
    var sut: WebAuthLogoutMethodHandler!

    override func setUpWithError() throws {
        spy = SpyWebAuth()
        sut = WebAuthLogoutMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension WebAuthLogoutHandlerTests {
    func testProducesErrorWhenUseHTTPSIsMissing() {
        let argument = Argument.useHTTPS
        let expectation = expectation(description: "\(argument.rawValue) is missing")
        sut.handle(with: arguments(without: argument)) { result in
            assert(result: result, isError: .requiredArgumentMissing(argument.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension WebAuthLogoutHandlerTests {

    // MARK: useHTTPS

    func testEnablesUseHTTPS() {
        let value = true
        sut.handle(with: arguments(withKey: Argument.useHTTPS, value: value)) { _ in }
        XCTAssertEqual(spy.useHTTPSValue, value)
    }

    func testDoesNotEnableUseHTTPSWhenFalse() {
        sut.handle(with: arguments(withKey: Argument.useHTTPS, value: false)) { _ in }
        XCTAssertNil(spy.useHTTPSValue)
    }

    // MARK: returnTo

    func testAddsReturnTo() {
        let value = "https://auth0.com"
        sut.handle(with: arguments(withKey: Argument.returnTo, value: value)) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, value)
    }

    func testDoesNotAddReturnToWhenNil() {
        sut.handle(with: arguments(without: Argument.returnTo)) { _ in }
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


// MARK: - Helpers

extension WebAuthLogoutHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.useHTTPS.rawValue: false,
            Argument.returnTo.rawValue: ""
        ]
    }
}
