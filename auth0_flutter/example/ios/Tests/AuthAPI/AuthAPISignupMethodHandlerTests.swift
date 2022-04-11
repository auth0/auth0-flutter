import XCTest
import Auth0

@testable import auth0_flutter

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
        let inputs = ["email": self.expectation(description: "email is missing"),
                      "password": self.expectation(description: "password is missing"),
                      "connection": self.expectation(description: "connection is missing")]
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

extension AuthAPISignupMethodHandlerTests {

    // MARK: email

    func testAddsEmail() {
        let key = "email"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: password

    func testAddsPassword() {
        let key = "password"
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

    // MARK: username

    func testAddsUsername() {
        let key = "username"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        let argument = "username"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument])
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
        return ["email": "",
                "password": "",
                "connection": "",
                "username": "",
                "userMetadata": [:]]
    }
}
