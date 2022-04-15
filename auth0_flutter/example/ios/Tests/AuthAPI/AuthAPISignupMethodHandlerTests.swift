import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPISignupMethodHandler.Argument

class AuthAPISignupMethodHandlerTests: XCTestCase {
    let spy = SpyAuthentication()
    var sut: AuthAPISignupMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPISignupMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPISignupMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.email, .password, .connection]
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

extension AuthAPISignupMethodHandlerTests {

    // MARK: email

    func testAddsEmail() {
        let key = Argument.email
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
    }

    // MARK: password

    func testAddsPassword() {
        let key = Argument.password
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

    // MARK: username

    func testAddsUsername() {
        let key = Argument.username
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
    }

    func testDoesNotAddUsernameWhenNil() {
        let argument = Argument.username
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument.rawValue])
    }
}

// MARK: - Signup Result

extension AuthAPISignupMethodHandlerTests {
    func testCallsSDKSignupMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledSignup)
    }

    func testProducesDatabaseUser() {
        let databaseUser = (email: "foo", username: "bar", verified: true)
        let expectation = self.expectation(description: "Produced a database user")
        spy.databaseUserResult = .success(databaseUser)
        sut.handle(with: arguments()) { result in
            assertHas(databaseUser: databaseUser, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.databaseUserResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assertHas(authenticationError: error, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPISignupMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.email.rawValue: "",
                Argument.password.rawValue: "",
                Argument.connection.rawValue: "",
                Argument.username.rawValue: "",
                Argument.userMetadata.rawValue: [:]]
    }
}

fileprivate extension AuthAPISignupMethodHandlerTests {
    func arguments<T>(key: Argument, value: T) -> [String: Any] {
        return arguments(key: key.rawValue, value: value)
    }

    func arguments(without key: Argument) -> [String: Any] {
        return arguments(without: key.rawValue)
    }
}
