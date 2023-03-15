import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPILoginWithOTPMethodHandler.Argument

class AuthAPILoginWithOTPMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPILoginWithOTPMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPILoginWithOTPMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPILoginWithOTPMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.otp, .mfaToken, .parameters]
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

// MARK: - ID Token Decoding Failed Error

extension AuthAPILoginWithOTPMethodHandlerTests {
    func testProducesErrorWithInvalidIDToken() {
        let credentials = Credentials(idToken: "foo")
        let expectation = self.expectation(description: "ID Token cannot be decoded")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: .idTokenDecodingFailed)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension AuthAPILoginWithOTPMethodHandlerTests {

    // MARK: otp

    func testAddsOTP() {
        let key = Argument.otp
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: mfaToken

    func testAddsMFAToken() {
        let key = Argument.mfaToken
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }
}

// MARK: - Login Result

extension AuthAPILoginWithOTPMethodHandlerTests {
    func testCallsSDKLoginWithOTPMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledLoginWithOTP)
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.credentialsResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
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

extension AuthAPILoginWithOTPMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.otp.rawValue: "",
            Argument.mfaToken.rawValue: "",
            Argument.parameters.rawValue: [:]
        ]
    }
}
