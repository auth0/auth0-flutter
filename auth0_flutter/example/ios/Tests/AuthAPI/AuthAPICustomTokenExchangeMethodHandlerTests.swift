import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPICustomTokenExchangeMethodHandler.Argument

class AuthAPICustomTokenExchangeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPICustomTokenExchangeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPICustomTokenExchangeMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.subjectToken, .subjectTokenType]
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

// MARK: - Successful Result

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testCallsCustomTokenExchange() {
        let expectation = self.expectation(description: "Called customTokenExchange")
        spy.onCustomTokenExchange = { subjectToken, subjectTokenType, audience, scope, organization in
            XCTAssertEqual(subjectToken, "existing-token")
            XCTAssertEqual(subjectTokenType, "http://acme.com/legacy-token")
            XCTAssertEqual(audience, "https://example.com/api")
            XCTAssertEqual(scope, "openid profile email")
            XCTAssertNil(organization)
            expectation.fulfill()
        }
        sut.handle(with: arguments()) { _ in }
        wait(for: [expectation])
    }

    func testReturnsCredentialsOnSuccess() {
        let expectation = self.expectation(description: "Returned credentials")
        let credentials = Credentials(
            accessToken: "access-token",
            tokenType: "bearer",
            idToken: "id-token",
            refreshToken: "refresh-token",
            expiresIn: Date(timeIntervalSinceNow: 3600),
            scope: "openid profile email"
        )
        spy.onCustomTokenExchange = { _, _, _, _ in
            return self.spy.request(returning: credentials)
        }
        sut.handle(with: arguments()) { result in
            let values = result as? [String: Any]
            XCTAssertNotNil(values)
            XCTAssertEqual(values?[CredentialsProperty.accessToken.rawValue] as? String, "access-token")
            XCTAssertEqual(values?[CredentialsProperty.idToken.rawValue] as? String, "id-token")
            XCTAssertEqual(values?[CredentialsProperty.refreshToken.rawValue] as? String, "refresh-token")
            XCTAssertEqual(values?[CredentialsProperty.tokenType.rawValue] as? String, "bearer")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Optional Parameters

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testWorksWithoutAudience() {
        let expectation = self.expectation(description: "Called without audience")
        spy.onCustomTokenExchange = { _, _, audience, _, _ in
            XCTAssertNil(audience)
            expectation.fulfill()
        }
        sut.handle(with: arguments(without: .audience)) { _ in }
        wait(for: [expectation])
    }

    func testWorksWithEmptyScopes() {
        let expectation = self.expectation(description: "Called with empty scopes")
        spy.onCustomTokenExchange = { _, _, _, scope, _ in
            XCTAssertEqual(scope, "openid profile email")
            expectation.fulfill()
        }
        var args = arguments()
        args[Argument.scopes.rawValue] = []
        sut.handle(with: args) { _ in }
        wait(for: [expectation])
    }

    func testWorksWithoutOrganization() {
        let expectation = self.expectation(description: "Called without organization")
        spy.onCustomTokenExchange = { _, _, _, _, organization in
            XCTAssertNil(organization)
            expectation.fulfill()
        }
        sut.handle(with: arguments(without: .organization)) { _ in }
        wait(for: [expectation])
    }

    func testIncludesOrganizationWhenProvided() {
        let expectation = self.expectation(description: "Called with organization")
        spy.onCustomTokenExchange = { subjectToken, subjectTokenType, audience, scope, organization in
            XCTAssertEqual(subjectToken, "existing-token")
            XCTAssertEqual(subjectTokenType, "http://acme.com/legacy-token")
            XCTAssertEqual(audience, "https://example.com/api")
            XCTAssertEqual(scope, "openid profile email")
            XCTAssertEqual(organization, "org_abc123")
            expectation.fulfill()
        }
        var args = arguments()
        args[Argument.organization.rawValue] = "org_abc123"
        sut.handle(with: args) { _ in }
        wait(for: [expectation])
    }
}

// MARK: - Error

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testReturnsAuthenticationErrorOnFailure() {
        let expectation = self.expectation(description: "Returned error")
        let authError = AuthenticationError(
            info: ["error": "invalid_grant", "error_description": "Invalid token"]
        )
        spy.onCustomTokenExchange = { _, _, _, _ in
            return self.spy.request(failing: authError)
        }
        sut.handle(with: arguments()) { result in
            assert(result: result, isAuthenticationError: authError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

fileprivate extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func arguments(without key: Argument? = nil) -> [String: Any] {
        var args: [String: Any] = [
            Argument.subjectToken.rawValue: "existing-token",
            Argument.subjectTokenType.rawValue: "http://acme.com/legacy-token",
            Argument.audience.rawValue: "https://example.com/api",
            Argument.scopes.rawValue: ["openid", "profile", "email"]
        ]
        if let key = key {
            args.removeValue(forKey: key.rawValue)
        }
        return args
    }
}
// MARK: - Spy Extension

fileprivate extension SpyAuthentication {
    var onCustomTokenExchange: ((String, String, String?, String?, String?) -> Request<Credentials, AuthenticationError>)?

    func customTokenExchange(subjectToken: String, 
                           subjectTokenType: String, 
                           audience: String?, 
                           scope: String?,
                           organization: String?) -> Request<Credentials, AuthenticationError> {
        return onCustomTokenExchange?(subjectToken, subjectTokenType, audience, scope, organization) ?? request()
    }
}   }
}
