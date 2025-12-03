import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerGetMethodHandler.Argument

class CredentialsManagerGetMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var sut: CredentialsManagerGetMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
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

// MARK: - Arguments

extension CredentialsManagerGetMethodHandlerTests {

    // MARK: scopes

    func testAddsScopes() {
        let value = ["foo", "bar"]
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: -3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced credentials")
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments(withKey: Argument.scopes, value: value)) { _ in
            XCTAssertEqual(self.spyAuthentication.arguments["scope"] as? String, value.asSpaceSeparatedString)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAddsNilScopeWhenEmpty() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: -3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced credentials")
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments(withKey: Argument.scopes, value: [])) { _ in
            XCTAssertNil(self.spyAuthentication.arguments["scope"] as? String)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Get Result

extension CredentialsManagerGetMethodHandlerTests {
    func testCallsSDKGetMethod() {
        let expectation = self.expectation(description: "Called get credentials method from the SDK")
        sut.handle(with: arguments()) { _ in
            XCTAssertTrue(self.spyStorage.calledGetEntry)
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
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced credentials")
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

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

extension CredentialsManagerGetMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.scopes.rawValue: [], Argument.minTtl.rawValue: 1, Argument.parameters.rawValue: [:]]
    }
}
