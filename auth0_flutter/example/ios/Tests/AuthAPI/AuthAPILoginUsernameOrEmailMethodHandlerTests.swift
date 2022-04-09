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
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let inputs = ["usernameOrEmail": self.expectation(description: "usernameOrEmail is missing"),
                      "password": self.expectation(description: "password is missing"),
                      "realmOrConnection": self.expectation(description: "realmOrConnection is missing"),
                      "scopes": self.expectation(description: "scopes is missing"),
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

// MARK: - Arguments

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {

    // MARK: usernameOrEmail

    func testAddsUsernameOrEmail() {
        let key = "usernameOrEmail"
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

    // MARK: realmOrConnection

    func testAddsRealmOrConnection() {
        let key = "realmOrConnection"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        sut.handle(with: arguments(key: "scopes", value: value)) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, value.asSpaceSeparatedString)
    }

    func testAddsDefaultScopesWhenEmpty() {
        sut.handle(with: arguments(key: "scopes", value: [])) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, Auth0.defaultScope)
    }

    // MARK: audience

    func testAddsAudience() {
        let key = "audience"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        let argument = "audience"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument])
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

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return ["usernameOrEmail": "",
                "password": "",
                "realmOrConnection": "",
                "scopes": [],
                "parameters": [:],
                "audience": ""]
    }
}
