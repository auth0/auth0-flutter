import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = CredentialsManagerGetMethodHandler.Argument

// MARK: - Test Spy

fileprivate class SpyCredentialsManager: CredentialsManager {
    var credentialsCalled = false
    var renewCalled = false

    var credentialsCallback: ((Result<Credentials, CredentialsManagerError>) -> Void)?

    override func credentials(withScope scope: String? = nil,
                              minTTL: Int = 0,
                              parameters: [String: Any] = [:],
                              headers: [String: String] = [:],
                              callback: @escaping (Result<Credentials, CredentialsManagerError>) -> Void) {
        self.credentialsCalled = true
        self.credentialsCallback = callback
    }

    override func renew(withParameters parameters: [String: Any] = [:],
                        headers: [String: String] = [:],
                        callback: @escaping (Result<Credentials, CredentialsManagerError>) -> Void) {
        self.renewCalled = true
        self.credentialsCallback = callback
    }
}

// MARK: - Test Case

class CredentialsManagerGetMethodHandlerTests: XCTestCase {
    var spy: SpyCredentialsManager!
    var sut: CredentialsManagerGetMethodHandler!

    override func setUpWithError() throws {
        spy = SpyCredentialsManager(authentication: SpyAuthentication(), storage: SpyCredentialsStorage())
        sut = CredentialsManagerGetMethodHandler(credentialsManager: spy)
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

// MARK: - Force Refresh

extension CredentialsManagerGetMethodHandlerTests {
    func testCallsRenewWhenForceRefreshIsTrue() {
        let expectation = self.expectation(description: "Called renew method")
        var arguments = self.arguments()
        arguments[Argument.forceRefresh.rawValue] = true

        sut.handle(with: arguments) { _ in }
        XCTAssertTrue(self.spy.renewCalled)
        XCTAssertFalse(self.spy.credentialsCalled)
        expectation.fulfill()
        wait(for: [expectation])
    }

    func testCallsCredentialsWhenForceRefreshIsFalse() {
        let expectation = self.expectation(description: "Called credentials method")
        var arguments = self.arguments()
        arguments[Argument.forceRefresh.rawValue] = false

        sut.handle(with: arguments) { _ in }
        XCTAssertFalse(self.spy.renewCalled)
        XCTAssertTrue(self.spy.credentialsCalled)
        expectation.fulfill()
        wait(for: [expectation])
    }

    func testCallsCredentialsWhenForceRefreshIsOmitted() {
        let expectation = self.expectation(description: "Called credentials method")

        sut.handle(with: arguments()) { _ in }
        XCTAssertFalse(self.spy.renewCalled)
        XCTAssertTrue(self.spy.credentialsCalled)
        expectation.fulfill()
        wait(for: [expectation])
    }
}


// MARK: - Get Result

extension CredentialsManagerGetMethodHandlerTests {
    func testCallsSDKGetMethod() {
        let expectation = self.expectation(description: "Called credentials method from the SDK")
        sut.handle(with: arguments()) { _ in
            XCTAssertTrue(self.spy.credentialsCalled)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentials() {
        let credentials = Credentials.from(idToken: testIdToken, accessToken: "accessToken")
        let expectation = self.expectation(description: "Produced credentials")
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        spy.credentialsCallback?(.success(credentials))
        wait(for: [expectation])
    }

    func testProducesCredentialsManagerError() {
        let error = CredentialsManagerError.noCredentials
        let expectation = self.expectation(description: "Produced the CredentialsManagerError \(error)")
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        spy.credentialsCallback?(.failure(error))
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension CredentialsManagerGetMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.scopes.rawValue: [],
            Argument.minTtl.rawValue: 0,
            Argument.parameters.rawValue: [:],
            // forceRefresh is omitted to test default behavior
        ]
    }
}
