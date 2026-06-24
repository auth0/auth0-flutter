import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = ApiCredentialsMethodHandler.Argument

final class ApiCredentialsMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var sut: ApiCredentialsMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
        sut = ApiCredentialsMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension ApiCredentialsMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.audience, .scopes, .minTtl, .parameters, .headers]
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

// MARK: - API Credentials Exchange

extension ApiCredentialsMethodHandlerTests {
    func testExchangeIsCalledWithAudienceAndScope() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "scope")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "API credentials exchange was called")
        spyAuthentication.credentialsResult = .success(credentials)
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments()) { _ in
            XCTAssertEqual(self.spyAuthentication.arguments["refreshToken"] as? String, "refreshToken")
            XCTAssertEqual(self.spyAuthentication.arguments["audience"] as? String, "test-audience")
            XCTAssertEqual(self.spyAuthentication.arguments["scope"] as? String, "a b")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesApiCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "a b")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced API credentials")
        spyAuthentication.credentialsResult = .success(credentials)
        spyStorage.getEntryReturnValue = data
        sut.handle(with: arguments()) { result in
            guard let dictionary = result as? [String: Any] else {
                return XCTFail("The handler did not produce a dictionary")
            }
            XCTAssertEqual(dictionary.keys.sorted(),
                           ["accessToken", "expiresAt", "scopes", "tokenType"])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Error

extension ApiCredentialsMethodHandlerTests {
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

extension ApiCredentialsMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.audience.rawValue: "test-audience",
            Argument.scopes.rawValue: ["a", "b"],
            Argument.minTtl.rawValue: 0,
            Argument.parameters.rawValue: [String: Any](),
            Argument.headers.rawValue: [String: String]()
        ]
    }
}
