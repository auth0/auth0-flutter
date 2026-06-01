#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
fileprivate typealias Argument = AuthAPIPasskeyLoginMethodHandler.Argument

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeyLoginMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIPasskeyLoginMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIPasskeyLoginMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginMethodHandlerTests {
    func testProducesErrorWhenChallengeIsMissing() {
        let expectation = self.expectation(description: "challenge is missing")
        sut.handle(with: arguments(without: .challenge)) { result in
            assert(result: result, isError: .requiredArgumentMissing(Argument.challenge.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenCredentialIsMissing() {
        let expectation = self.expectation(description: "credential is missing")
        sut.handle(with: arguments(without: .credential)) { result in
            assert(result: result, isError: .requiredArgumentMissing(Argument.credential.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginMethodHandlerTests {
    func testAddsConnectionAudienceScopeAndOrganization() {
        var args = arguments()
        args[Argument.connection.rawValue] = "test-connection"
        args[Argument.audience.rawValue] = "test-audience"
        args[Argument.scopes.rawValue] = ["a", "b"]
        args[Argument.organization.rawValue] = "test-org"
        sut.handle(with: args) { _ in }
        XCTAssertEqual(spy.arguments["connection"] as? String, "test-connection")
        XCTAssertEqual(spy.arguments["audience"] as? String, "test-audience")
        XCTAssertEqual(spy.arguments["scope"] as? String, "a b")
        XCTAssertEqual(spy.arguments["organization"] as? String, "test-org")
    }
}

// MARK: - Login Result

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginMethodHandlerTests {
    func testCallsSDKLoginWithPasskeyMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLoginWithPasskey)
    }

    func testProducesCredentials() {
        let credentials = Credentials(idToken: testIdToken)
        spy.credentialsResult = .success(credentials)
        let expectation = self.expectation(description: "Produced credentials")
        sut.handle(with: arguments()) { result in
            XCTAssertNotNil(result as? [String: Any])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.credentialsResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyLoginMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.challenge.rawValue: [
                "authSession": "test-auth-session",
                "authParamsPublicKey": [
                    "challenge": "dGVzdC1jaGFsbGVuZ2U",
                    "rpId": "test-rp-id"
                ]
            ],
            Argument.credential.rawValue: [
                "id": "dGVzdC1jcmVkZW50aWFs",
                "rawId": "dGVzdC1jcmVkZW50aWFs",
                "type": "public-key",
                "authenticatorAttachment": "platform",
                "response": [
                    "clientDataJSON": "dGVzdC1jbGllbnQtZGF0YQ",
                    "authenticatorData": "dGVzdC1hdXRoLWRhdGE",
                    "signature": "dGVzdC1zaWduYXR1cmU",
                    "userHandle": "dGVzdC11c2VyLWhhbmRsZQ"
                ]
            ]
        ]
    }

    fileprivate func arguments(without argument: Argument) -> [String: Any] {
        var args = arguments()
        args.removeValue(forKey: argument.rawValue)
        return args
    }
}
#endif
