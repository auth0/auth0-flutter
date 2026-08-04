import XCTest
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPILoginWithOTPMethodHandler.Argument

class AuthAPILoginWithOTPMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: AuthAPILoginWithOTPMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = AuthAPILoginWithOTPMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPILoginWithOTPMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.otp, .mfaToken]
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
        spy.verifyResult = .success(credentials)
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
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.otp, value: value)) { _ in }
        XCTAssertEqual(spy.verifyOtpArg, value)
    }

    // MARK: mfaToken

    func testAddsMFAToken() {
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.mfaToken, value: value)) { _ in }
        XCTAssertTrue(spy.calledVerify)
    }
}

// MARK: - Login Result

extension AuthAPILoginWithOTPMethodHandlerTests {
    func testCallsSDKLoginWithOTPMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledVerify)
    }

    func testProducesCredentials() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresAt: Date(),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Produced credentials")
        spy.verifyResult = .success(credentials)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: CredentialsProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesMFAVerifyError() {
        let error = MFAVerifyError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the MFAVerifyError \(error)")
        spy.verifyResult = .failure(error)
        sut.handle(with: arguments()) { result in
            guard let flutterError = result as? FlutterError else {
                return XCTFail("The handler did not produce a FlutterError")
            }
            XCTAssertEqual(flutterError.code, error.code)
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
            Argument.mfaToken.rawValue: ""
        ]
    }
}
