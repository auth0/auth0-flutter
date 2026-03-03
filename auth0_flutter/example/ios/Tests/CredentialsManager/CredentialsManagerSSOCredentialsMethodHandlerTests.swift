import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = SSOCredentialsMethodHandler.Argument

final class SSOCredentialsMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var sut: SSOCredentialsMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
        sut = SSOCredentialsMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension SSOCredentialsMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.parameters, .headers]
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

// MARK: - SSO Credentials

extension SSOCredentialsMethodHandlerTests {
    func testSSOExchangeIsCalled() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "scope")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "SSO exchange was called")
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments()) { _ in
            XCTAssertEqual(self.spyAuthentication.arguments["refreshToken"] as? String, "refreshToken")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesSSO() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "scope")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced SSO credentials")
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments()) { result in
            let expectedKeys: [SSOCredentialsProperty] = [
                .sessionTransferToken, .tokenType, .expiresIn, .idToken
            ]
            assert(result: result, has: expectedKeys)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Error

extension SSOCredentialsMethodHandlerTests {
    func testProducesCredentialsManagerError() {
        let error = CredentialsManagerError.noCredentials
        let expectation = self.expectation(description: "Produced the CredentialsManagerError \(error)")
        spyStorage.getEntryReturnValue = nil
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension SSOCredentialsMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.parameters.rawValue: [String: String](),
            Argument.headers.rawValue: [String: String]()
        ]
    }
}
