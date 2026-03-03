import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = SSOExchangeMethodHandler.Argument

class AuthAPISSOExchangeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: SSOExchangeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = SSOExchangeMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPISSOExchangeMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.refreshToken, .parameters, .headers]
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

// MARK: - SSO Exchange

extension AuthAPISSOExchangeMethodHandlerTests {
    func testCallsSSOExchangeWithRefreshToken() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertEqual(spy.arguments["refreshToken"] as? String, "test-refresh-token")
    }

    func testProducesSSOCredentials() {
        let expectation = self.expectation(description: "Produced SSO credentials")
        sut.handle(with: arguments()) { result in
            let expectedKeys: [SSOCredentialsProperty] = [
                .sessionTransferToken, .tokenType, .expiresIn, .idToken
            ]
            assert(result: result, has: expectedKeys)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testIncludesRefreshTokenWhenPresent() {
        let ssoCredentials = SSOCredentials(
            sessionTransferToken: "session-token",
            issuedTokenType: "urn:ietf:params:oauth:token-type:session_transfer",
            expiresIn: Date(timeIntervalSinceNow: 60),
            idToken: testIdToken,
            refreshToken: "new-refresh-token"
        )
        let expectation = self.expectation(description: "Included refresh token in result")
        spy.ssoCredentialsResult = .success(ssoCredentials)
        sut.handle(with: arguments()) { result in
            let values = result as? [String: Any]
            XCTAssertEqual(values?[SSOCredentialsProperty.refreshToken.rawValue] as? String, "new-refresh-token")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testDoesNotIncludeRefreshTokenWhenAbsent() {
        let expectation = self.expectation(description: "No refresh token in result")
        sut.handle(with: arguments()) { result in
            let values = result as? [String: Any]
            XCTAssertNil(values?[SSOCredentialsProperty.refreshToken.rawValue])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Error

extension AuthAPISSOExchangeMethodHandlerTests {
    func testProducesAuthenticationErrorOnFailure() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced authentication error")
        spy.ssoCredentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPISSOExchangeMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.refreshToken.rawValue: "test-refresh-token",
            Argument.parameters.rawValue: [String: Any](),
            Argument.headers.rawValue: [String: String]()
        ]
    }
}
