#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
fileprivate typealias Argument = AuthAPIPasskeySignupMethodHandler.Argument

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeySignupMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIPasskeySignupMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIPasskeySignupMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupMethodHandlerTests {
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
extension AuthAPIPasskeySignupMethodHandlerTests {
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

// MARK: - Signup Result

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupMethodHandlerTests {
    func testCallsSDKLoginWithSignupPasskeyMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledSignupWithPasskey)
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

// MARK: - Reconstruct Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupMethodHandlerTests {
    func testReconstructPasskeyReturnsValidPasskey() {
        let credentialMap: [String: Any] = [
            "id": "dGVzdC1jcmVkZW50aWFs",
            "rawId": "dGVzdC1jcmVkZW50aWFs",
            "type": "public-key",
            "authenticatorAttachment": "platform",
            "response": [
                "clientDataJSON": "dGVzdC1jbGllbnQtZGF0YQ",
                "attestationObject": "dGVzdC1hdHRlc3RhdGlvbg"
            ]
        ]
        let passkey = AuthAPIPasskeySignupMethodHandler.reconstructPasskey(from: credentialMap)
        XCTAssertNotNil(passkey)
        XCTAssertEqual(passkey?.credentialID.base64URLEncodedString(), "dGVzdC1jcmVkZW50aWFs")
    }

    func testReconstructPasskeyReturnsNilForMissingResponse() {
        let credentialMap: [String: Any] = [
            "id": "dGVzdC1jcmVkZW50aWFs",
            "type": "public-key"
        ]
        let passkey = AuthAPIPasskeySignupMethodHandler.reconstructPasskey(from: credentialMap)
        XCTAssertNil(passkey)
    }

    func testReconstructChallengeReturnsValidChallenge() {
        let challengeMap: [String: Any] = [
            "authSession": "test-auth-session",
            "authParamsPublicKey": [
                "challenge": "dGVzdC1jaGFsbGVuZ2U",
                "rpId": "test-rp-id",
                "userId": "dGVzdC11c2VyLWlk",
                "userName": "test-user-name"
            ]
        ]
        let challenge = AuthAPIPasskeySignupMethodHandler.reconstructChallenge(from: challengeMap)
        XCTAssertNotNil(challenge)
    }

    func testReconstructChallengeReturnsNilForMissingAuthSession() {
        let challengeMap: [String: Any] = [
            "authParamsPublicKey": [
                "challenge": "dGVzdC1jaGFsbGVuZ2U",
                "rpId": "test-rp-id"
            ]
        ]
        let challenge = AuthAPIPasskeySignupMethodHandler.reconstructChallenge(from: challengeMap)
        XCTAssertNil(challenge)
    }
}

// MARK: - Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeySignupMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.challenge.rawValue: [
                "authSession": "test-auth-session",
                "authParamsPublicKey": [
                    "challenge": "dGVzdC1jaGFsbGVuZ2U",
                    "rpId": "test-rp-id",
                    "userId": "dGVzdC11c2VyLWlk",
                    "userName": "test-user-name"
                ]
            ],
            Argument.credential.rawValue: [
                "id": "dGVzdC1jcmVkZW50aWFs",
                "rawId": "dGVzdC1jcmVkZW50aWFs",
                "type": "public-key",
                "authenticatorAttachment": "platform",
                "response": [
                    "clientDataJSON": "dGVzdC1jbGllbnQtZGF0YQ",
                    "attestationObject": "dGVzdC1hdHRlc3RhdGlvbg"
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
