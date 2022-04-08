import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPILoginUsernameOrEmailMethodHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
    + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
    + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyAuthentication(clientId: "foo", url: URL(string: "https://auth0.com")!, telemetry: Telemetry())
    var sut: AuthAPILoginUsernameOrEmailMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPILoginUsernameOrEmailMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {

    // MARK: usernameOrEmail

    func testProducesErrorWhenUsernameOrEmailIsMissing() {
        let argument = "usernameOrEmail"
        let arguments: [String: Any] = arguments(without: argument)
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenUsernameOrEmailIsNoString() {
        let argument = "usernameOrEmail"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not a string")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: password

    func testProducesErrorWhenPasswordIsMissing() {
        let argument = "password"
        let arguments: [String: Any] = arguments(without: argument)
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenPasswordIsNoString() {
        let argument = "password"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not a string")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: realmOrConnection

    func testProducesErrorWhenRealmOrConnectionIsMissing() {
        let argument = "realmOrConnection"
        let arguments: [String: Any] = arguments(without: argument)
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenRealmOrConnectionIsNoString() {
        let argument = "realmOrConnection"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not a string")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: scopes

    func testProducesErrorWhenScopesIsMissing() {
        let argument = "scopes"
        let arguments: [String: Any] = arguments(without: argument)
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenScopesIsNoStringsArray() {
        let argument = "scopes"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not an array of strings")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: parameters

    func testProducesErrorWhenParametersIsMissing() {
        let argument = "parameters"
        let arguments: [String: Any] = arguments(without: argument)
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenParametersIsNoStringsDictionary() {
        let argument = "parameters"
        let arguments: [String: Any] = arguments(key: argument, anyValue: ["foo": 1])
        let expectation = self.expectation(description: "\(argument) is not a dictionary of strings")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - ID Token Decoding Failed Error

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func testProducesErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            print((result as!  FlutterError).code)
            assertHas(handlerError: .idTokenDecodingFailed, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Optional Arguments

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {

    // MARK: audience

    func testAddsAudience() {
        let audience = "foo"
        let key = "audience"
        sut.handle(with: arguments(key: key, value: audience)) { _ in }
        XCTAssertNotNil(spy.arguments[key])
        XCTAssertEqual(spy.arguments[key] as? String, audience)
    }

    func testDoesNotAddAudienceWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.arguments["audience"])
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
        let expectation = self.expectation(description: "Produced the Authentication error \(error)")
        spy.credentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assertHas(authenticationError: error, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

private extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func arguments(username: String = "",
                   password: String = "",
                   realm: String = "",
                   scopes: [String] = [],
                   parameters: [String: Any] = [:]) -> [String: Any] {
        return ["usernameOrEmail": username,
                "password": password,
                "realmOrConnection": realm,
                "scopes": scopes,
                "parameters": parameters]
    }

    func arguments<T>(key: String, value: T) -> [String: Any] {
        var arguments = arguments()
        arguments[key] =  value
        return arguments
    }

    func arguments(without key: String) -> [String: Any] {
        var arguments = arguments()
        arguments.removeValue(forKey: key)
        return arguments
    }

    func arguments(key: String, anyValue value: Any) -> [String: Any] {
        var arguments = arguments()
        arguments[key] = value
        return arguments
    }
}
