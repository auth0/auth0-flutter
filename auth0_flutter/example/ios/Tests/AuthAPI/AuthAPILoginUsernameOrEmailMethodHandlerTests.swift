import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPILoginUsernameOrEmailMethodHandler.Argument

class AuthAPILoginUsernameOrEmailMethodHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
        + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
        + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyAuthentication()
    var sut: AuthAPILoginUsernameOrEmailMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPILoginUsernameOrEmailMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.usernameOrEmail, .password, .connectionOrRealm, .scopes, .parameters]
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

// MARK: - ID Token Decoding Failed Error

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func testProducesErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(handlerError: .idTokenDecodingFailed, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {

    // MARK: usernameOrEmail

    func testAddsUsernameOrEmail() {
        let key = Argument.usernameOrEmail
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

    // MARK: connectionOrRealm

    func testAddsconnectionOrRealm() {
        let key = Argument.connectionOrRealm
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        sut.handle(with: arguments(key: .scopes, value: value)) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, value.asSpaceSeparatedString)
    }

    func testAddsDefaultScopesWhenEmpty() {
        sut.handle(with: arguments(key: .scopes, value: [])) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, Auth0.defaultScope)
    }

    // MARK: audience

    func testAddsAudience() {
        let key = Argument.audience
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key.rawValue] as? String, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        let argument = Argument.audience
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument.rawValue])
    }
}

// MARK: - Login Result

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func testCallsSDKLoginMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLoginWithUsernameOrEmail)
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      idToken: idToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentialsWithoutRefreshToken() {
        let credentials = Credentials(idToken: idToken, refreshToken: nil)
        let expectation = self.expectation(description: "Produced credentials without a refresh token")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.credentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assertHas(authenticationError: error, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.usernameOrEmail.rawValue: "",
                Argument.password.rawValue: "",
                Argument.connectionOrRealm.rawValue: "",
                Argument.scopes.rawValue: [],
                Argument.parameters.rawValue: [:],
                Argument.audience.rawValue: ""]
    }
}

fileprivate extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func arguments<T>(key: Argument, value: T) -> [String: Any] {
        return arguments(key: key.rawValue, value: value)
    }

    func arguments(without key: Argument) -> [String: Any] {
        return arguments(without: key.rawValue)
    }
}
