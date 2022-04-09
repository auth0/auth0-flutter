import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPIRenewAccessTokenMethodHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
        + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
        + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyAuthentication(clientId: "", url: URL(string: "https://example.com")!, telemetry: Telemetry())
    var sut: AuthAPIRenewAccessTokenMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPIRenewAccessTokenMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPIRenewAccessTokenMethodHandlerTests {
    func testProducesErrorWhenAccessTokenIsMissing() {
        let argument = "refreshToken"
        let expectation = self.expectation(description: "\(argument) is missing")
        sut.handle(with: arguments(without: argument)) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - ID Token Decoding Failed Error

extension AuthAPIRenewAccessTokenMethodHandlerTests {
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

extension AuthAPIRenewAccessTokenMethodHandlerTests {

    // MARK: refreshToken

    func testAddsAccessToken() {
        let key = "refreshToken"
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

    func testDoesNotAddScopesWhenEmpty() {
        sut.handle(with: arguments(key: "scopes", value:  [])) { _ in }
        XCTAssertNil(spy.arguments["scope"])
    }
}

// MARK: - Renew Result

extension AuthAPIRenewAccessTokenMethodHandlerTests {
    func testCallsSDKRenewAccessTokenMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledRenewAccessToken)
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

extension AuthAPIRenewAccessTokenMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return ["refreshToken": "", "scopes": []]
    }
}
