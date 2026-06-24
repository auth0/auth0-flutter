import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = ClearApiCredentialsMethodHandler.Argument

class ClearApiCredentialsMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: ClearApiCredentialsMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = ClearApiCredentialsMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Required Arguments Error

extension ClearApiCredentialsMethodHandlerTests {
    func testProducesErrorWhenAudienceIsMissing() {
        let expectation = self.expectation(description: "audience is missing")
        sut.handle(with: arguments(without: Argument.audience)) { result in
            assert(result: result, isError: .requiredArgumentMissing(Argument.audience.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Clear Result

extension ClearApiCredentialsMethodHandlerTests {
    func testCallsSDKClearMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledDeleteEntry)
    }

    func testProducesTrueOnSuccess() {
        let expectation = self.expectation(description: "Produced true")
        spy.deleteEntryReturnValue = true
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFalseOnFailure() {
        let expectation = self.expectation(description: "Produced false")
        spy.deleteEntryReturnValue = false
        sut.handle(with: arguments()) { result in
            XCTAssertEqual(result as? Bool, false)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension ClearApiCredentialsMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.audience.rawValue: "test-audience",
            Argument.scope.rawValue: "test-scope"
        ]
    }
}
