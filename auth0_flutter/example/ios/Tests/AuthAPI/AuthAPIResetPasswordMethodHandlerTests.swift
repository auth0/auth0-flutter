import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIResetPasswordMethodHandler.Argument

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
        let keys: [Argument] = [.email, .connection, .parameters]
        let expectations = keys.map({ expectation(description: "\($0.rawValue) is missing") })
        for (argument, currentExpectation) in zip(keys, expectations) {
            sut.handle(with: arguments(without: argument.rawValue)) { result in
                assertHas(handlerError: .requiredArgumentMissing(argument.rawValue), result)
                currentExpectation.fulfill()
            }
        }
        wait(for: expectations)
    }
}

// MARK: - Arguments

extension AuthAPIResetPasswordMethodHandlerTests {

    // MARK: email

    func testAddsEmail() {
        let key = Argument.email
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
    }

    // MARK: connection

    func testAddsConnection() {
        let key = Argument.connection
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
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
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
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
        return [Argument.email.rawValue: "", Argument.connection.rawValue: "", Argument.parameters.rawValue: [:]]
    }
}

fileprivate extension AuthAPIResetPasswordMethodHandlerTests {
    func arguments<T>(key: Argument, value: T) -> [String: Any] {
        return arguments(key: key.rawValue, value: value)
    }
}
