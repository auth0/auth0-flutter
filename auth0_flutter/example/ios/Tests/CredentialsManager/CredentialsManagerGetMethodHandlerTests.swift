import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerGetMethodHandler.Argument

class CredentialsManagerGetMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: CredentialsManagerGetMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = CredentialsManagerGetMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension CredentialsManagerGetMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.scopes, .minTtl, .parameters]
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

// MARK: - Logout Result

extension CredentialsManagerGetMethodHandlerTests {
    func testCallsSDKGetMethod() {
        let expectation = self.expectation(description: "Called get credentials method from the SDK")
        sut.handle(with: arguments()) { _ in
            XCTAssertTrue(self.spy.calledGetEntry)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        spy.getEntryReturnValue = data
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentialsManagerError() {
        let error = CredentialsManagerError.noCredentials
        let expectation = self.expectation(description: "Produced the CredentialsManagerError \(error)")
        spy.getEntryReturnValue = nil
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension CredentialsManagerGetMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.scopes.rawValue: [], Argument.minTtl.rawValue: 1, Argument.parameters.rawValue: [:]]
    }
}
