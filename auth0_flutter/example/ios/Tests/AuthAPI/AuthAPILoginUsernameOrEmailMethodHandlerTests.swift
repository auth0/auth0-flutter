import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPILoginUsernameOrEmailMethodHandler.Argument

class AuthAPILoginUsernameOrEmailMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPILoginUsernameOrEmailMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPILoginUsernameOrEmailMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.usernameOrEmail, .password, .connectionOrRealm, .scopes, .parameters]
        let expectations = keys.map { expectation(description: "\($0.rawValue) is missing") }
        for (argument, currentExpectation) in zip(keys, expectations) {
            sut.handle(with: arguments(without: argument)) { result in
                assert(result: result, isError: .requiredArgumentMissing(argument.rawValue))
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
            assert(result: result, isError: .idTokenDecodingFailed)
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
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: password

    func testAddsPassword() {
        let key = Argument.password
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: connectionOrRealm

    func testAddsConnectionOrRealm() {
        let key = Argument.connectionOrRealm
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        sut.handle(with: arguments(withKey: Argument.scopes, value: value)) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, value.asSpaceSeparatedString)
    }

    func testAddsDefaultScopesWhenEmpty() {
        sut.handle(with: arguments(withKey: Argument.scopes, value: [])) { _ in }
        XCTAssertEqual(spy.arguments["scope"] as? String, Auth0.defaultScope)
    }

    // MARK: audience

    func testAddsAudience() {
        let key = Argument.audience
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        let argument = Argument.audience
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
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.credentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPILoginUsernameOrEmailMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.usernameOrEmail.rawValue: "",
            Argument.password.rawValue: "",
            Argument.connectionOrRealm.rawValue: "",
            Argument.scopes.rawValue: [],
            Argument.parameters.rawValue: [:],
            Argument.audience.rawValue: ""
        ]
    }
}
