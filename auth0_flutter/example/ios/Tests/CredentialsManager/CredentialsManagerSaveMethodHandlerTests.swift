import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerSaveMethodHandler.Argument

class CredentialsManagerSaveMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: CredentialsManagerSaveMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = CredentialsManagerSaveMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension CredentialsManagerSaveMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentIsMissing() {
        let argument = Argument.credentials
        let expectation = self.expectation(description: "\(argument.rawValue) is missing")
        sut.handle(with: arguments(without: argument)) { result in
            assert(result: result, isError: .requiredArgumentMissing(argument.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Logout Result

extension CredentialsManagerSaveMethodHandlerTests {
    func testCallsSDKSaveMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledSetEntry)
    }

    func testProducesTrueOnSuccess() {
        let expectation = self.expectation(description: "Produced true")
        spy.setEntryReturnValue = true
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFalseOnFailure() {
        let expectation = self.expectation(description: "Produced false")
        spy.setEntryReturnValue = false
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, false)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension CredentialsManagerSaveMethodHandlerTests {
    override func arguments() -> [String: Any] {
        let credentials: [String: Any] = [
            CredentialsProperty.accessToken.rawValue: "",
            CredentialsProperty.idToken.rawValue: "",
            CredentialsProperty.refreshToken.rawValue: "",
            CredentialsProperty.expiresAt.rawValue: Date().asISO8601String,
            CredentialsProperty.scopes.rawValue: [],
            CredentialsProperty.tokenType.rawValue: ""
        ]
        return [Argument.credentials.rawValue: credentials]
    }
}
