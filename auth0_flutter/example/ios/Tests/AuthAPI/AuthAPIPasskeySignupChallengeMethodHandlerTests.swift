#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
fileprivate typealias Argument = AuthAPIPasskeySignupChallengeMethodHandler.Argument

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeySignupChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIPasskeySignupChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIPasskeySignupChallengeMethodHandler(client: spy)
    }
}

// MARK: - Arguments

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupChallengeMethodHandlerTests {
    func testAddsEmail() {
        let value = "test-email"
        sut.handle(with: arguments(withKey: Argument.email, value: value)) { _ in }
        XCTAssertEqual(spy.arguments["email"] as? String, value)
    }

    func testAddsConnectionAndOrganization() {
        var args: [String: Any] = [:]
        args[Argument.connection.rawValue] = "test-connection"
        args[Argument.organization.rawValue] = "test-org"
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["connection"] as? String, "test-connection")
        XCTAssertEqual(spy.arguments["organization"] as? String, "test-org")
    }

    func testAllArgumentsAreOptional() {
        sut.handle(with: [:]) { _ in }
        XCTAssertTrue(spy.calledPasskeySignupChallenge)
        XCTAssertNil(spy.arguments["email"] as? String)
    }

    func testAddsUserMetadata() {
        var args: [String: Any] = [:]
        args[Argument.userMetadata.rawValue] = ["plan": "gold"]
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["userMetadata"] as? [String: String], ["plan": "gold"])
    }

    func testAddsProfileIdentifiers() {
        var args: [String: Any] = [:]
        args[Argument.givenName.rawValue] = "test-given-name"
        args[Argument.familyName.rawValue] = "test-family-name"
        args[Argument.nickname.rawValue] = "test-nickname"
        args[Argument.picture.rawValue] = "https://www.okta.com"
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["givenName"] as? String, "test-given-name")
        XCTAssertEqual(spy.arguments["familyName"] as? String, "test-family-name")
        XCTAssertEqual(spy.arguments["nickname"] as? String, "test-nickname")
        XCTAssertEqual(spy.arguments["picture"] as? String, "https://www.okta.com")
    }
}

// MARK: - Challenge Result

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupChallengeMethodHandlerTests {
    func testCallsSDKPasskeySignupChallengeMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledPasskeySignupChallenge)
    }

    func testProducesChallengeResponse() {
        let expectation = self.expectation(description: "Produced a challenge response")
        sut.handle(with: arguments()) { result in
            let dictionary = result as? [String: Any]
            XCTAssertEqual(dictionary?["authSession"] as? String, "test-auth-session")
            let publicKey = dictionary?["authParamsPublicKey"] as? [String: Any]
            XCTAssertEqual(publicKey?["rpId"] as? String, "test-rp-id")
            XCTAssertEqual(publicKey?["userName"] as? String, "test-user-name")
            XCTAssertNotNil(publicKey?["challenge"] as? String)
            XCTAssertNotNil(publicKey?["userId"] as? String)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.passkeySignupChallengeResultOverride = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupChallengeMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [:]
    }
}
#endif
