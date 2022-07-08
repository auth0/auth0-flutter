import XCTest
import Auth0

@testable import auth0_flutter

class CredentialsManagerClearMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: CredentialsManagerClearMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = CredentialsManagerClearMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Clear Result

extension CredentialsManagerClearMethodHandlerTests {
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
