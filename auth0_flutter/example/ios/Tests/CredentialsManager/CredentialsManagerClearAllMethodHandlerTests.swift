import XCTest
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import auth0_flutter

final class CredentialsManagerClearAllMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsStorage!
    var sut: CredentialsManagerClearAllMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: SpyAuthentication(), storage: spy)
        sut = CredentialsManagerClearAllMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Clear All Result

extension CredentialsManagerClearAllMethodHandlerTests {
    func testCallsSDKClearAllMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledDeleteAllEntries)
    }

    func testProducesNilOnSuccess() {
        let expectation = self.expectation(description: "Produced nil")
        spy.deleteAllEntriesReturnValue = true
        sut.handle(with: arguments()) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced a FlutterError")
        spy.deleteAllEntriesReturnValue = false
        sut.handle(with: arguments()) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
