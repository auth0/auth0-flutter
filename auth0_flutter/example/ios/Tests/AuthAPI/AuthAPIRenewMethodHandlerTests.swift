import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIRenewMethodHandler.Argument

class AuthAPIRenewMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIRenewMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIRenewMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPIRenewMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.refreshToken, .scopes, .parameters]
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

extension AuthAPIRenewMethodHandlerTests {
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

extension AuthAPIRenewMethodHandlerTests {

    // MARK: refreshToken

    func testAddsAccessToken() {
        let key = Argument.refreshToken
        let value = "foo"
        let expectation = self.expectation(description: "Handler completes")
        sut.handle(with: arguments(withKey: key, value: value)) { _ in
            XCTAssertEqual(self.spy.arguments[key] as? String, value)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        let expectation = self.expectation(description: "Handler completes")
        sut.handle(with: arguments(withKey: Argument.scopes, value: value)) { _ in
            XCTAssertEqual(self.spy.arguments["scope"] as? String, value.asSpaceSeparatedString)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testDoesNotAddScopesWhenEmpty() {
        let expectation = self.expectation(description: "Handler completes")
        sut.handle(with: arguments(withKey: Argument.scopes, value:  [])) { _ in
            XCTAssertNil(self.spy.arguments["scope"])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Renew Result

extension AuthAPIRenewMethodHandlerTests {
    func testCallsSDKRenewMethod() {
        let expectation = self.expectation(description: "Calls SDK renew method")
        sut.handle(with: arguments()) { _ in
            XCTAssertTrue(self.spy.calledRenew)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
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

extension AuthAPIRenewMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.refreshToken.rawValue: "", Argument.scopes.rawValue: [], Argument.parameters.rawValue: [:]]
    }
}
