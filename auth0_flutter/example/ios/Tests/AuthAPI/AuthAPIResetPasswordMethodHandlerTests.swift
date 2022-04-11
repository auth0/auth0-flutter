import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPIResetPasswordMethodHandlerTests: XCTestCase {
    let spy = SpyAuthentication()
    var sut: AuthAPIResetPasswordMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPIResetPasswordMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPIResetPasswordMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let inputs = ["email": self.expectation(description: "email is missing"),
                      "connection": self.expectation(description: "connection is missing"),
                      "parameters": self.expectation(description: "parameters is missing")]
        for (argument, currentExpectation) in inputs {
            sut.handle(with: arguments(without: argument)) { result in
                assertHas(handlerError: .requiredArgumentsMissing, result)
                currentExpectation.fulfill()
            }
        }
        wait(for: Array(inputs.values))
    }
}

// MARK: - Arguments

extension AuthAPIResetPasswordMethodHandlerTests {

    // MARK: email

    func testAddsEmail() {
        let key = "email"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: connection

    func testAddsConnection() {
        let key = "connection"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }
}

// MARK: - Renew Result

extension AuthAPIResetPasswordMethodHandlerTests {
    func testCallsSDKRenewAccessTokenMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledResetPassword)
    }

    func testProducesNil() {
        let expectation = self.expectation(description: "Produced nil")
        spy.voidResult = .success(())
        sut.handle(with: arguments()) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the Authentication error \(error)")
        spy.voidResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assertHas(authenticationError: error, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPIResetPasswordMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return ["email": "", "connection": "", "parameters": [:]]
    }
}
