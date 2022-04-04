import XCTest
import Flutter
import Auth0

@testable import auth0_flutter

class WebAuthLoginHandlerTests: XCTestCase {
    let idToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmb28iLCJuYW1lIjoiYmFyIiwiZW1haWwiOiJmb29AZXhhbXBsZS5"
        + "jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGljdHVyZSI6ImJheiIsInVwZGF0ZWRfYXQiOiJxdXgifQ.vc9sxvhUVAHowIWJ7D_WDzvq"
        + "JxC4-qYXHmiBVYEKn9E"
    let spy = SpyWebAuth(clientId: "foo", url: URL(string: "https://auth0.com")!, telemetry: Telemetry.init())
    var sut: WebAuthLoginMethodHandler!

    override func setUpWithError() throws {
        sut = WebAuthLoginMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension WebAuthLoginHandlerTests {
    func testProducesErrorWhenScopesIsMissing() {
        let arguments: [String: Any] = ["parameters": [:], "useEphemeralSession": false]
        let expectation = self.expectation(description: "scopes is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenScopesIsNoStringsArray() {
        let arguments: [String: Any] = ["scopes": 1, "parameters": [:], "useEphemeralSession": false]
        let expectation = self.expectation(description: "scopes is not an array of strings")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenParametersIsMissing() {
        let arguments: [String: Any] = ["scopes": [], "useEphemeralSession": false]
        let expectation = self.expectation(description: "parameters is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenParametersIsNoStringsDictionary() {
        let arguments: [String: Any] = ["parameters": ["foo": 1], "scopes": [], "useEphemeralSession": false]
        let expectation = self.expectation(description: "parameters is not a dictionary of strings")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenUseEphemeralSessionIsMissing() {
        let arguments: [String: Any] = ["scopes": [], "parameters": [:]]
        let expectation = self.expectation(description: "parameters is missing")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenUseEphemeralSessionIsNoBool() {
        let arguments: [String: Any] = ["useEphemeralSession": 1, "scopes": [], "parameters": [:]]
        let expectation = self.expectation(description: "useEphemeralSession is not a bool")
        sut.handle(with: arguments) { result in
            assertHas(handlerError: .requiredArgumentsMissing, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - ID Token Decoding Failed Error

extension WebAuthLoginHandlerTests {
    func testProduceErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(handlerError: .idTokenDecodingFailed, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Optional Arguments

extension WebAuthLoginHandlerTests {

    // MARK: scopes

    func testAddsScopes() {
        let scopes = ["foo", "bar"]
        sut.handle(with: arguments(scopes: scopes)) { _ in }
        XCTAssertEqual(spy.scopeValue, scopes.joined(separator: " "))
    }

    func testDoesNotAddScopesWhenEmpty() {
        let scopes: [String] = []
        sut.handle(with: arguments(scopes: scopes)) { _ in }
        XCTAssertNil(spy.scopeValue)
    }

    // MARK: useEphemeralSession

    func testEnablesUseEphemeralSession() {
        let useEphemeralSession = true
        sut.handle(with: arguments(useEphemeralSession: useEphemeralSession)) { _ in }
        XCTAssertEqual(spy.useEmphemeralSessionValue, true)
    }

    func testDoesEnableUseEphemeralSessionWhenFalse() {
        let useEphemeralSession = false
        sut.handle(with: arguments(useEphemeralSession: useEphemeralSession)) { _ in }
        XCTAssertNil(spy.useEmphemeralSessionValue)
    }

    // MARK: audience

    func testAddsAudience() {
        let audience = "foo"
        sut.handle(with: arguments(key: "audience", value: audience)) { _ in }
        XCTAssertEqual(spy.audienceValue, audience)
    }

    func testDoesNotAddAudienceWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.audienceValue)
    }

    // MARK: redirectUri

    func testAddsRedirectURL() {
        let redirectURL = "https://auth0.com"
        sut.handle(with: arguments(key: "redirectUri", value: redirectURL)) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, redirectURL)
    }

    func testDoesNotAddRedirectURLWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }

    // MARK: organizationId

    func testAddsOrganizationId() {
        let organizationId = "foo"
        sut.handle(with: arguments(key: "organizationId", value: organizationId)) { _ in }
        XCTAssertEqual(spy.organizationValue, organizationId)
    }

    func testDoesNotAddOrganizationIdWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.organizationValue)
    }

    // MARK: invitationUrl

    func testAddsInvitationURL() {
        let invitationURL = "https://auth0.com"
        sut.handle(with: arguments(key: "invitationUrl", value: invitationURL)) { _ in }
        XCTAssertEqual(spy.invitationURLValue?.absoluteString, invitationURL)
    }

    func testDoesNotAddInvitationURLWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.invitationURLValue)
    }

    // MARK: leeway

    func testAddsLeeway() {
        let leeway = 1_000
        sut.handle(with: arguments(key: "leeway", value: leeway)) { _ in }
        XCTAssertEqual(spy.leewayValue, leeway)
    }

    func testDoesNotAddLeewayWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.leewayValue)
    }

    // MARK: issuer

    func testAddsIssuer() {
        let issuer = "foo"
        sut.handle(with: arguments(key: "issuer", value: issuer)) { _ in }
        XCTAssertEqual(spy.issuerValue, issuer)
    }

    func testDoesNotAddIssuerWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.issuerValue)
    }

    // MARK: maxAge

    func testAddsMaxAge() {
        let maxAge = 1_000
        sut.handle(with: arguments(key: "maxAge", value: maxAge)) { _ in }
        XCTAssertEqual(spy.maxAgeValue, maxAge)
    }

    func testDoesNotAddMaxAgeWhenNil() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNil(spy.maxAgeValue)
    }
}

// MARK: - Login Result

extension WebAuthLoginHandlerTests {
    func testCallSDKLoginMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLogin)
    }

    func testProduceCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      idToken: idToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProduceCredentialsWithoutRefreshToken() {
        let credentials = Credentials(idToken: idToken, refreshToken: nil)
        let expectation = self.expectation(description: "Produced credentials without a refresh token")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assertHas(credentials: credentials, in: result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Helpers

private extension WebAuthLoginHandlerTests {
    func arguments(scopes: [String] = [],
                   parameters: [String: String] = [:],
                   useEphemeralSession: Bool = false) -> [String: Any] {
        return ["scopes": scopes,
                "parameters": parameters,
                "useEphemeralSession": useEphemeralSession]

    }

    func arguments<T>(key: String, value: T) -> [String: Any] {
        var arguments = arguments()
        arguments[key] =  value
        return arguments
    }
}
