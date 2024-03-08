import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = WebAuthLoginMethodHandler.Argument

class WebAuthLoginHandlerTests: XCTestCase {
    var spy: SpyWebAuth!
    var sut: WebAuthLoginMethodHandler!

    #if os(iOS)
    var spySafariProvider: SpySafariProvider!
    #endif

    override func setUpWithError() throws {
        spy = SpyWebAuth()

        #if os(iOS)
        spySafariProvider = SpySafariProvider()
        sut = WebAuthLoginMethodHandler(client: spy, safariProvider: spySafariProvider.provider)
        #else
        sut = WebAuthLoginMethodHandler(client: spy)
        #endif
    }
}

// MARK: - Required Arguments Error

extension WebAuthLoginHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.useHTTPS, .useEphemeralSession, .scopes, .parameters]
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

extension WebAuthLoginHandlerTests {
    func testProducesErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: .idTokenDecodingFailed)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension WebAuthLoginHandlerTests {

    // MARK: useHTTPS

    func testEnablesUseHTTPS() {
        let value = true
        sut.handle(with: arguments(withKey: Argument.useHTTPS, value: value)) { _ in }
        XCTAssertEqual(spy.useHTTPSValue, value)
    }

    func testDoesNotEnableUseHTTPSWhenFalse() {
        sut.handle(with: arguments(withKey: Argument.useHTTPS, value: false)) { _ in }
        XCTAssertNil(spy.useHTTPSValue)
    }

    // MARK: useEphemeralSession

    func testEnablesUseEphemeralSession() {
        let value = true
        sut.handle(with: arguments(withKey: Argument.useEphemeralSession, value: value)) { _ in }
        XCTAssertEqual(spy.useEmphemeralSessionValue, value)
    }

    func testDoesNotEnableUseEphemeralSessionWhenFalse() {
        sut.handle(with: arguments(withKey: Argument.useEphemeralSession, value: false)) { _ in }
        XCTAssertNil(spy.useEmphemeralSessionValue)
    }

    // MARK: parameters

    func testAddsParameters() {
        let value = ["foo": "bar"]
        sut.handle(with: arguments(withKey: Argument.parameters, value: value)) { _ in }
        XCTAssertEqual(spy.parametersValue, value)
    }

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        sut.handle(with: arguments(withKey: Argument.scopes, value: value)) { _ in }
        XCTAssertEqual(spy.scopeValue, value.asSpaceSeparatedString)
    }

    func testAddsEmptyScopeWhenEmpty() {
        sut.handle(with: arguments(withKey: Argument.scopes, value:  [])) { _ in }
        XCTAssertEqual(spy.scopeValue, "")
    }

    // MARK: audience

    func testAddsAudience() {
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.audience, value: value)) { _ in }
        XCTAssertEqual(spy.audienceValue, value)
    }

    func testDoesNotAddAudienceWhenNil() {
        sut.handle(with: arguments(without: Argument.audience)) { _ in }
        XCTAssertNil(spy.audienceValue)
    }

    // MARK: redirectUrl

    func testAddsRedirectURL() {
        let value = "https://auth0.com"
        sut.handle(with: arguments(withKey: Argument.redirectUrl, value: value)) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, value)
    }

    func testDoesNotAddRedirectURLWhenNil() {
        sut.handle(with: arguments(without: Argument.redirectUrl)) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }

    // MARK: organizationId

    func testAddsOrganizationId() {
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.organizationId, value: value)) { _ in }
        XCTAssertEqual(spy.organizationValue, value)
    }

    func testDoesNotAddOrganizationIdWhenNil() {
        sut.handle(with: arguments(without: Argument.organizationId)) { _ in }
        XCTAssertNil(spy.organizationValue)
    }

    // MARK: invitationUrl

    func testAddsInvitationURL() {
        let value = "https://auth0.com"
        sut.handle(with: arguments(withKey: Argument.invitationUrl, value: value)) { _ in }
        XCTAssertEqual(spy.invitationURLValue?.absoluteString, value)
    }

    func testDoesNotAddInvitationURLWhenNil() {
        sut.handle(with: arguments(without: Argument.invitationUrl)) { _ in }
        XCTAssertNil(spy.invitationURLValue)
    }

    // MARK: leeway

    func testAddsLeeway() {
        let value = 1_000
        sut.handle(with: arguments(withKey: Argument.leeway, value: value)) { _ in }
        XCTAssertEqual(spy.leewayValue, value)
    }

    func testDoesNotAddLeewayWhenNil() {
        sut.handle(with: arguments(without: Argument.leeway)) { _ in }
        XCTAssertNil(spy.leewayValue)
    }

    // MARK: issuer

    func testAddsIssuer() {
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.issuer, value: value)) { _ in }
        XCTAssertEqual(spy.issuerValue, value)
    }

    func testDoesNotAddIssuerWhenNil() {
        sut.handle(with: arguments(without: Argument.issuer)) { _ in }
        XCTAssertNil(spy.issuerValue)
    }

    // MARK: maxAge

    func testAddsMaxAge() {
        let value = 1_000
        sut.handle(with: arguments(withKey: Argument.maxAge, value: value)) { _ in }
        XCTAssertEqual(spy.maxAgeValue, value)
    }

    func testDoesNotAddMaxAgeWhenNil() {
        sut.handle(with: arguments(without: Argument.maxAge)) { _ in }
        XCTAssertNil(spy.maxAgeValue)
    }

    #if os(iOS)
    // MARK: safariViewController

    func testAddsSafariViewController() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertNotNil(spy.provider)
    }

    func testDoesNotAddSafariViewController() {
        sut.handle(with: arguments(without: SafariViewController.key)) { _ in }
        XCTAssertNil(spy.provider)
    }

    func testAddSafariViewControllerWithStyle() {
        let value = [SafariViewControllerProperty.presentationStyle.rawValue: 2]
        sut.handle(with: arguments(withKey: SafariViewController.key, value: value)) { _ in }
        XCTAssertEqual(spySafariProvider.presentationStyle, UIModalPresentationStyle.formSheet)
    }
    #endif
}

// MARK: - Login Result

extension WebAuthLoginHandlerTests {
    func testCallsSDKLoginMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLogin)
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.loginResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesWebAuthError() {
        let error = WebAuthError.userCancelled
        let expectation = self.expectation(description: "Produced a WebAuthError")
        spy.loginResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension WebAuthLoginHandlerTests {
    override func arguments() -> [String: Any] {
        var values: [String: Any] = [
            Argument.scopes.rawValue: [],
            Argument.parameters.rawValue: [:],
            Argument.useHTTPS.rawValue: false,
            Argument.useEphemeralSession.rawValue: false,
            Argument.audience.rawValue: "",
            Argument.redirectUrl.rawValue: "https://example.com",
            Argument.organizationId.rawValue: "",
            Argument.invitationUrl.rawValue: "https://example.com",
            Argument.leeway.rawValue: 1,
            Argument.issuer.rawValue: "",
            Argument.maxAge.rawValue: 1,
        ]

        #if os(iOS)
        values[Argument.safariViewController.rawValue] = [:]
        #endif

        return values
    }
}
