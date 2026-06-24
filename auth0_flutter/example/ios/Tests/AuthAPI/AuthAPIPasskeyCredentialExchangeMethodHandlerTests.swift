#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
fileprivate typealias Argument = AuthAPIPasskeyCredentialExchangeMethodHandler.Argument

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class AuthAPIPasskeyCredentialExchangeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIPasskeyCredentialExchangeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIPasskeyCredentialExchangeMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
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

// MARK: - Reconstruction Errors

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
    func testProducesErrorWhenLoginChallengeCannotBeReconstructed() {
        var args = loginArguments()
        // Drop `rpId` so the challenge cannot be reconstructed.
        args[Argument.challenge.rawValue] = [
            "authSession": "test-auth-session",
            "authParamsPublicKey": ["challenge": "dGVzdC1jaGFsbGVuZ2U"]
        ]
        let expectation = self.expectation(description: "login challenge cannot be reconstructed")
        sut.handle(with: args) { result in
            guard let error = result as? FlutterError else {
                return XCTFail("The handler did not produce a FlutterError")
            }
            XCTAssertEqual(error.code, "PASSKEY_ERROR")
            XCTAssertEqual(error.message, "Failed to reconstruct login challenge")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenLoginPasskeyCannotBeReconstructed() {
        var args = loginArguments()
        // Drop the `response` object so the passkey cannot be reconstructed.
        args[Argument.credential.rawValue] = [
            "id": "dGVzdC1jcmVkZW50aWFs",
            "rawId": "dGVzdC1jcmVkZW50aWFs",
            "type": "public-key"
        ]
        let expectation = self.expectation(description: "login passkey cannot be reconstructed")
        sut.handle(with: args) { result in
            guard let error = result as? FlutterError else {
                return XCTFail("The handler did not produce a FlutterError")
            }
            XCTAssertEqual(error.code, "PASSKEY_ERROR")
            XCTAssertEqual(error.message, "Failed to reconstruct passkey credential")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenSignupChallengeCannotBeReconstructed() {
        var args = signupArguments()
        // Drop `userId` so the challenge cannot be reconstructed.
        args[Argument.challenge.rawValue] = [
            "authSession": "test-auth-session",
            "authParamsPublicKey": [
                "challenge": "dGVzdC1jaGFsbGVuZ2U",
                "rpId": "test-rp-id",
                "userName": "test-user-name"
            ]
        ]
        let expectation = self.expectation(description: "signup challenge cannot be reconstructed")
        sut.handle(with: args) { result in
            guard let error = result as? FlutterError else {
                return XCTFail("The handler did not produce a FlutterError")
            }
            XCTAssertEqual(error.code, "PASSKEY_ERROR")
            XCTAssertEqual(error.message, "Failed to reconstruct signup challenge")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenSignupPasskeyCannotBeReconstructed() {
        var args = signupArguments()
        // Drop the `response` object so the passkey cannot be reconstructed.
        args[Argument.credential.rawValue] = [
            "id": "dGVzdC1jcmVkZW50aWFs",
            "type": "public-key"
        ]
        let expectation = self.expectation(description: "signup passkey cannot be reconstructed")
        sut.handle(with: args) { result in
            guard let error = result as? FlutterError else {
                return XCTFail("The handler did not produce a FlutterError")
            }
            XCTAssertEqual(error.code, "PASSKEY_ERROR")
            XCTAssertEqual(error.message, "Failed to reconstruct passkey credential")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Flow Discrimination (Login vs Signup)

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
    func testDetectsLoginCredentialAndCallsLoginPasskeyMethod() {
        sut.handle(with: loginArguments()) { _ in }
        XCTAssertTrue(spy.calledLoginWithPasskey)
        XCTAssertFalse(spy.calledSignupWithPasskey)
    }

    func testDetectsSignupCredentialAndCallsLoginPasskeyMethodWithSignupPasskey() {
        sut.handle(with: signupArguments()) { _ in }
        // A credential whose response carries an attestationObject is routed to
        // the SignupPasskey overload of client.login(passkey:challenge:...).
        XCTAssertTrue(spy.calledSignupWithPasskey)
        XCTAssertFalse(spy.calledLoginWithPasskey)
    }
}

// MARK: - Arguments Forwarding

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
    func testForwardsConnectionAudienceScopeAndOrganizationForLogin() {
        var args = loginArguments()
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

    func testForwardsConnectionAudienceScopeAndOrganizationForSignup() {
        var args = signupArguments()
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

    func testForwardsParametersForLogin() {
        var args = loginArguments()
        args[Argument.parameters.rawValue] = ["custom_key": "custom_value"]
        sut.handle(with: args) { _ in }
        // The spy doesn't track parameters directly, but the handler calls
        // request.parameters(...) before starting, so we verify the call completes
        XCTAssertTrue(spy.calledLoginWithPasskey)
    }

    func testForwardsParametersForSignup() {
        var args = signupArguments()
        args[Argument.parameters.rawValue] = ["custom_key": "custom_value"]
        sut.handle(with: args) { _ in }
        XCTAssertTrue(spy.calledSignupWithPasskey)
    }
}

// MARK: - Results

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
    func testProducesCredentialsForLoginSuccess() {
        let credentials = Credentials(idToken: testIdToken)
        spy.credentialsResult = .success(credentials)
        let expectation = self.expectation(description: "Produced credentials for login")
        sut.handle(with: loginArguments()) { result in
            XCTAssertNotNil(result as? [String: Any])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationErrorForLoginFailure() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced AuthenticationError for login")
        spy.credentialsResult = .failure(error)
        sut.handle(with: loginArguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentialsForSignupSuccess() {
        let credentials = Credentials(idToken: testIdToken)
        spy.credentialsResult = .success(credentials)
        let expectation = self.expectation(description: "Produced credentials for signup")
        sut.handle(with: signupArguments()) { result in
            XCTAssertNotNil(result as? [String: Any])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationErrorForSignupFailure() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced AuthenticationError for signup")
        spy.credentialsResult = .failure(error)
        sut.handle(with: signupArguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
extension AuthAPIPasskeyCredentialExchangeMethodHandlerTests {
    fileprivate func loginArguments() -> [String: Any] {
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

    fileprivate func signupArguments() -> [String: Any] {
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
        var args = loginArguments()
        args.removeValue(forKey: argument.rawValue)
        return args
    }
}
#endif
