import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = WebAuthLoginMethodHandler.Argument

class WebAuthLoginHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
        + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
        + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyWebAuth()
    var sut: WebAuthLoginMethodHandler!

    override func setUpWithError() throws {
        sut = WebAuthLoginMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension WebAuthLoginHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.useEphemeralSession, .scopes, .parameters]
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

extension WebAuthLoginHandlerTests {
    func testProducesErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(handlerError: .idTokenDecodingFailed, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension WebAuthLoginHandlerTests {

    // MARK: useEphemeralSession

    func testEnablesUseEphemeralSession() {
        let value = true
        sut.handle(with: arguments(key: .useEphemeralSession, value: value)) { _ in }
        XCTAssertEqual(spy.useEmphemeralSessionValue, value)
    }

    func testDoesNotEnableUseEphemeralSessionWhenFalse() {
        sut.handle(with: arguments(key: .useEphemeralSession, value: false)) { _ in }
        XCTAssertNil(spy.useEmphemeralSessionValue)
    }

    // MARK: parameters

    func testAddsParameters() {
        let value = ["foo": "bar"]
        sut.handle(with: arguments(key: .parameters, value: value)) { _ in }
        XCTAssertEqual(spy.parametersValue, value)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        sut.handle(with: arguments(key: .scopes, value: value)) { _ in }
        XCTAssertEqual(spy.scopeValue, value.asSpaceSeparatedString)
    }

    func testDoesNotAddScopesWhenEmpty() {
        sut.handle(with: arguments(key: .scopes, value:  [])) { _ in }
        XCTAssertNil(spy.scopeValue)
    }

    // MARK: audience

    func testAddsAudience() {
        let value = "foo"
        sut.handle(with: arguments(key: .audience, value: value)) { _ in }
        XCTAssertEqual(spy.audienceValue, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        sut.handle(with: arguments(without: .audience)) { _ in }
        XCTAssertNil(spy.audienceValue)
    }

    // MARK: redirectUri

    func testAddsRedirectURL() {
        let value = "https://auth0.com"
        sut.handle(with: arguments(key: .redirectUri, value: value)) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, value)
    }

    func testDoesNotAddRedirectURLWhenNil() {
        sut.handle(with: arguments(without: .redirectUri)) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }

    // MARK: organizationId

    func testAddsOrganizationId() {
        let value = "foo"
        sut.handle(with: arguments(key: .organizationId, value: value)) { _ in }
        XCTAssertEqual(spy.organizationValue, value)
    }

    func testDoesNotAddOrganizationIdWhenNil() {
        sut.handle(with: arguments(without: .organizationId)) { _ in }
        XCTAssertNil(spy.organizationValue)
    }

    // MARK: invitationUrl

    func testAddsInvitationURL() {
        let value = "https://auth0.com"
        sut.handle(with: arguments(key: .invitationUrl, value: value)) { _ in }
        XCTAssertEqual(spy.invitationURLValue?.absoluteString, value)
    }

    func testDoesNotAddInvitationURLWhenNil() {
        sut.handle(with: arguments(without: .invitationUrl)) { _ in }
        XCTAssertNil(spy.invitationURLValue)
    }

    // MARK: leeway

    func testAddsLeeway() {
        let value = 1_000
        sut.handle(with: arguments(key: .leeway, value: value)) { _ in }
        XCTAssertEqual(spy.leewayValue, value)
    }

    func testDoesNotAddLeewayWhenNil() {
        sut.handle(with: arguments(without: .leeway)) { _ in }
        XCTAssertNil(spy.leewayValue)
    }

    // MARK: issuer

    func testAddsIssuer() {
        let value = "foo"
        sut.handle(with: arguments(key: .issuer, value: value)) { _ in }
        XCTAssertEqual(spy.issuerValue, value)
    }

    func testDoesNotAddIssuerWhenNil() {
        sut.handle(with: arguments(without: .issuer)) { _ in }
        XCTAssertNil(spy.issuerValue)
    }

    // MARK: maxAge

    func testAddsMaxAge() {
        let value = 1_000
        sut.handle(with: arguments(key: .maxAge, value: value)) { _ in }
        XCTAssertEqual(spy.maxAgeValue, value)
    }

    func testDoesNotAddMaxAgeWhenNil() {
        sut.handle(with: arguments(without: .maxAge)) { _ in }
        XCTAssertNil(spy.maxAgeValue)
    }
}

// MARK: - Login Result

extension WebAuthLoginHandlerTests {
    func testCallsSDKLoginMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLogin)
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      idToken: idToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentialsWithoutRefreshToken() {
        let credentials = Credentials(idToken: idToken, refreshToken: nil)
        let expectation = self.expectation(description: "Produced credentials without a refresh token")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesWebAuthError() {
        let errors: [String: WebAuthError] = ["USER_CANCELLED": .userCancelled,
                                              "ID_TOKEN_VALIDATION_FAILED": .idTokenValidationFailed,
                                              "INVALID_INVITATION_URL": .invalidInvitationURL,
                                              "NO_AUTHORIZATION_CODE": .noAuthorizationCode,
                                              "NO_BUNDLE_IDENTIFIER": .noBundleIdentifier,
                                              "PKCE_NOT_ALLOWED": .pkceNotAllowed,
                                              "OTHER": .other,
                                              "UNKNOWN": .unknown]
        var expectations: [XCTestExpectation] = []
        for (code, error) in errors {
            let expectation = self.expectation(description: "Produced the WebAuthError \(code)")
            expectations.append(expectation)
            spy.loginResult = .failure(error)
            sut.handle(with: arguments()) { result in
                assertHas(webAuthError: error, code: code, result)
                expectation.fulfill()
            }
        }
        wait(for: expectations)
    }
}

// MARK: - Helpers

extension WebAuthLoginHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.scopes.rawValue: [],
                Argument.parameters.rawValue: [:],
                Argument.useEphemeralSession.rawValue: false,
                Argument.audience.rawValue: "",
                Argument.redirectUri.rawValue: "https://example.com",
                Argument.organizationId.rawValue: "",
                Argument.invitationUrl.rawValue: "https://example.com",
                Argument.leeway.rawValue: 1,
                Argument.issuer.rawValue: "",
                Argument.maxAge.rawValue: 1]
    }
}

fileprivate extension WebAuthLoginHandlerTests {
    func arguments<T>(key: Argument, value: T) -> [String: Any] {
        return arguments(key: key.rawValue, value: value)
    }

    func arguments(without key: Argument) -> [String: Any] {
        return arguments(without: key.rawValue)
    }
}
