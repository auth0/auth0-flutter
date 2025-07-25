import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerRenewMethodHandler.Argument

class CredentialsManagerRenewMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var sut: CredentialsManagerRenewMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
        sut = CredentialsManagerRenewMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension CredentialsManagerRenewMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.parameters]
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

extension CredentialsManagerRenewMethodHandlerTests {

    func testRenewApiCalled() {
           let credentials = Credentials(accessToken: "accessToken",
                                         tokenType: "tokenType",
                                         idToken: testIdToken,
                                         refreshToken: "refreshToken",
                                         expiresIn: Date(),
                                         scope: "scope")
           let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
           let expectation = self.expectation(description: "Produced credentials")
           spyStorage.getEntryReturnValue = data
           sut.handle(with: arguments(withKey: Argument.parameters, value: [:])) { _ in
               XCTAssertEqual(self.spyAuthentication.calledRenew as Bool, true)
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
                                          scope: "scope")
            let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
            let expectation = self.expectation(description: "Produced credentials")
            spyAuthentication.credentialsResult = .success(credentials)
            spyStorage.getEntryReturnValue = data
            sut.handle(with: arguments(withKey: Argument.parameters, value: [:])) { result in
                assert(result: result, has: CredentialsProperty.allCases)
                expectation.fulfill()
            }
            wait(for: [expectation])
        }
}

extension CredentialsManagerRenewMethodHandlerTests {

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

extension CredentialsManagerRenewMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.parameters.rawValue: [:]]
    }
}

