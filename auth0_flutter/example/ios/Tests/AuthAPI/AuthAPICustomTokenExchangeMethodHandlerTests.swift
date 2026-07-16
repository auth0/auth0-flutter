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
        let keys: [Argument] = [.subjectToken, .subjectTokenType, .scopes]
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

// MARK: - Custom Token Exchange

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testCallsCustomTokenExchangeWithRequiredArguments() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledCustomTokenExchange)
        XCTAssertEqual(spy.arguments["subjectToken"] as? String, "existing-token")
        XCTAssertEqual(spy.arguments["subjectTokenType"] as? String, "http://acme.com/legacy-token")
        XCTAssertEqual(spy.arguments["audience"] as? String, "https://example.com/api")
        XCTAssertEqual(spy.arguments["scope"] as? String, "openid profile email")
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "openid profile email")
        let expectation = self.expectation(description: "Produced credentials")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Optional Parameters

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testWorksWithoutAudience() {
        sut.handle(with: arguments(without: .audience)) { _ in }
        XCTAssertNil(spy.arguments["audience"] as? String)
    }

    func testWorksWithoutOrganization() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.arguments["organization"] as? String)
    }

    func testIncludesOrganizationWhenProvided() {
        var args = arguments()
        args[Argument.organization.rawValue] = "org_abc123"
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["organization"] as? String, "org_abc123")
    }
}

// MARK: - Actor Token (Delegation / Impersonation)

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testPassesActorTokenWhenActorTokenAndTypeProvided() {
        var args = arguments()
        args[Argument.actorToken.rawValue] = "actor-token-value"
        args[Argument.actorTokenType.rawValue] = "urn:ietf:params:oauth:token-type:id_token"
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["actor_token"] as? String, "actor-token-value")
        XCTAssertEqual(spy.arguments["actor_token_type"] as? String,
                       "urn:ietf:params:oauth:token-type:id_token")
    }

    func testDoesNotPassActorTokenWhenOnlyActorTokenProvided() {
        var args = arguments()
        args[Argument.actorToken.rawValue] = "actor-token-value"
        sut.handle(with: args) { _ in }
        XCTAssertNil(spy.arguments["actor_token"] as? String)
        XCTAssertNil(spy.arguments["actor_token_type"] as? String)
    }

    func testDoesNotPassActorTokenWhenOnlyActorTokenTypeProvided() {
        var args = arguments()
        args[Argument.actorTokenType.rawValue] = "urn:ietf:params:oauth:token-type:id_token"
        sut.handle(with: args) { _ in }
        XCTAssertNil(spy.arguments["actor_token"] as? String)
        XCTAssertNil(spy.arguments["actor_token_type"] as? String)
    }
}

// MARK: - Error

extension AuthAPICustomTokenExchangeMethodHandlerTests {
    func testProducesAuthenticationErrorOnFailure() {
        let error = AuthenticationError(
            info: ["error": "invalid_grant", "error_description": "Invalid token"]
        )
        let expectation = self.expectation(description: "Produced authentication error")
        spy.credentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
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
