import XCTest
import Auth0

@testable import auth0_flutter

class WebAuthLoginHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
        + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
        + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyWebAuth(clientId: "foo", url: URL(string: "https://auth0.com")!, telemetry: Telemetry())
    var sut: WebAuthLoginMethodHandler!

    override func setUpWithError() throws {
        sut = WebAuthLoginMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension WebAuthLoginHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let inputs = ["useEphemeralSession": self.expectation(description: "useEphemeralSession is missing"),
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

    // MARK: scopes

    func testAddsScopes() {
        let scopes = ["foo", "bar"]
        sut.handle(with: arguments(key: "scopes", value: scopes)) { _ in }
        XCTAssertEqual(spy.scopeValue, scopes.asSpaceSeparatedString)
    }

    func testDoesNotAddScopesWhenEmpty() {
        sut.handle(with: arguments(key: "scopes", value:  [])) { _ in }
        XCTAssertNil(spy.scopeValue)
    }

    // MARK: useEphemeralSession

    func testEnablesUseEphemeralSession() {
        let useEphemeralSession = true
        sut.handle(with: arguments(key: "useEphemeralSession", value: useEphemeralSession)) { _ in }
        XCTAssertEqual(spy.useEmphemeralSessionValue, useEphemeralSession)
    }

    func testDoesNotEnableUseEphemeralSessionWhenFalse() {
        sut.handle(with: arguments(key: "useEphemeralSession", value: false)) { _ in }
        XCTAssertNil(spy.useEmphemeralSessionValue)
    }

    // MARK: audience

    func testAddsAudience() {
        let audience = "foo"
        sut.handle(with: arguments(key: "audience", value: audience)) { _ in }
        XCTAssertEqual(spy.audienceValue, audience)
    }

    func testDoesNotAddAudienceWhenNil() {
        let argument = "audience"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.audienceValue)
    }

    // MARK: redirectUri

    func testAddsRedirectURL() {
        let redirectURL = "https://auth0.com"
        sut.handle(with: arguments(key: "redirectUri", value: redirectURL)) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, redirectURL)
    }

    func testDoesNotAddRedirectURLWhenNil() {
        let argument = "redirectUri"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }

    // MARK: organizationId

    func testAddsOrganizationId() {
        let organizationId = "foo"
        sut.handle(with: arguments(key: "organizationId", value: organizationId)) { _ in }
        XCTAssertEqual(spy.organizationValue, organizationId)
    }

    func testDoesNotAddOrganizationIdWhenNil() {
        let argument = "organizationId"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.organizationValue)
    }

    // MARK: invitationUrl

    func testAddsInvitationURL() {
        let invitationURL = "https://auth0.com"
        sut.handle(with: arguments(key: "invitationUrl", value: invitationURL)) { _ in }
        XCTAssertEqual(spy.invitationURLValue?.absoluteString, invitationURL)
    }

    func testDoesNotAddInvitationURLWhenNil() {
        let argument = "invitationUrl"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.invitationURLValue)
    }

    // MARK: leeway

    func testAddsLeeway() {
        let leeway = 1_000
        sut.handle(with: arguments(key: "leeway", value: leeway)) { _ in }
        XCTAssertEqual(spy.leewayValue, leeway)
    }

    func testDoesNotAddLeewayWhenNil() {
        let argument = "leeway"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.leewayValue)
    }

    // MARK: issuer

    func testAddsIssuer() {
        let issuer = "foo"
        sut.handle(with: arguments(key: "issuer", value: issuer)) { _ in }
        XCTAssertEqual(spy.issuerValue, issuer)
    }

    func testDoesNotAddIssuerWhenNil() {
        let argument = "issuer"
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.issuerValue)
    }

    // MARK: maxAge

    func testAddsMaxAge() {
        let maxAge = 1_000
        sut.handle(with: arguments(key: "maxAge", value: maxAge)) { _ in }
        XCTAssertEqual(spy.maxAgeValue, maxAge)
    }

    func testDoesNotAddMaxAgeWhenNil() {
        let argument = "maxAge"
        sut.handle(with: arguments(without: argument)) { _ in }
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
            let expectation = self.expectation(description: "Produced the WebAuth error \(code)")
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
        return ["scopes": [],
                "parameters": [:],
                "useEphemeralSession": false,
                "audience": "",
                "redirectUri": "https://example.com",
                "organizationId": "",
                "invitationUrl": "https://example.com",
                "leeway": 1,
                "issuer": "",
                "maxAge": 1]
    }
}
