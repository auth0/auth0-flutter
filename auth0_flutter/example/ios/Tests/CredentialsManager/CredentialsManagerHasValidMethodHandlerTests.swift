import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerHasValidMethodHandler.Argument

class CredentialsManagerHasValidMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: CredentialsManagerHasValidMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = CredentialsManagerHasValidMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension CredentialsManagerHasValidMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentIsMissing() {
        let argument = Argument.minTtl
        let expectation = self.expectation(description: "\(argument.rawValue) is missing")
        sut.handle(with: arguments(without: argument)) { result in
            assert(result: result, isError: .requiredArgumentMissing(argument.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Has Valid Result

extension CredentialsManagerHasValidMethodHandlerTests {
    func testCallsSDKGetMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledGetEntry)
    }

    func testProducesTrueWithValidCredentials() {
        let credentials = Credentials(expiresIn: Date(timeIntervalSinceNow: 3600))
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Produced true")
        spy.getEntryReturnValue = data
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFalseWithNoValidCredentials() {
        let expectation = self.expectation(description: "Produced false")
        spy.getEntryReturnValue = nil
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, false)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension CredentialsManagerHasValidMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.minTtl.rawValue: 0]
    }
}
