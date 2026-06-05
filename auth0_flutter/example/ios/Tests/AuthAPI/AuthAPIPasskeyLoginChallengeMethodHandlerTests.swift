#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
fileprivate typealias Argument = AuthAPIPasskeyLoginChallengeMethodHandler.Argument

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeyLoginChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIPasskeyLoginChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIPasskeyLoginChallengeMethodHandler(client: spy)
    }
}

// MARK: - Arguments

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginChallengeMethodHandlerTests {
    func testAddsConnection() {
        let value = "test-connection"
        sut.handle(with: arguments(withKey: Argument.connection, value: value)) { _ in }
        XCTAssertEqual(spy.arguments["connection"] as? String, value)
    }

    func testAddsOrganization() {
        let value = "test-org"
        sut.handle(with: arguments(withKey: Argument.organization, value: value)) { _ in }
        XCTAssertEqual(spy.arguments["organization"] as? String, value)
    }

    func testConnectionAndOrganizationAreOptional() {
        sut.handle(with: [:]) { _ in }
        XCTAssertTrue(spy.calledPasskeyLoginChallenge)
        XCTAssertNil(spy.arguments["connection"] as? String)
        XCTAssertNil(spy.arguments["organization"] as? String)
    }
}

// MARK: - Challenge Result

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginChallengeMethodHandlerTests {
    func testCallsSDKPasskeyLoginChallengeMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledPasskeyLoginChallenge)
    }

    func testProducesChallengeResponse() {
        let expectation = self.expectation(description: "Produced a challenge response")
        sut.handle(with: arguments()) { result in
            let dictionary = result as? [String: Any]
            XCTAssertEqual(dictionary?["authSession"] as? String, "test-auth-session")
            let publicKey = dictionary?["authParamsPublicKey"] as? [String: Any]
            XCTAssertEqual(publicKey?["rpId"] as? String, "test-rp-id")
            XCTAssertNotNil(publicKey?["challenge"] as? String)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.passkeyLoginChallengeResultOverride = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginChallengeMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [:]
    }
}
#endif
