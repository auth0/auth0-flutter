import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MfaVerifyMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaVerifyMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaVerifyMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: ["grantType": "otp", "otp": "123456"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenGrantTypeMissing() {
        let expectation = self.expectation(description: "Missing grantType")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenOtpMissing() {
        let expectation = self.expectation(description: "Missing otp")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "otp"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenOobCodeMissing() {
        let expectation = self.expectation(description: "Missing oobCode")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "oob"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenRecoveryCodeMissing() {
        let expectation = self.expectation(description: "Missing recoveryCode")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "recovery_code"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorOnUnknownGrantType() {
        let expectation = self.expectation(description: "Unknown grantType")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "magic"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testVerifiesWithOtp() {
        let expectation = self.expectation(description: "Verified with OTP")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "otp", "otp": "123456"]) { _ in
            XCTAssertTrue(self.spy.calledVerify)
            XCTAssertEqual(self.spy.verifyOtpArg, "123456")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testVerifiesWithOobAndBindingCode() {
        let expectation = self.expectation(description: "Verified with OOB")
        sut.handle(with: [
            "mfaToken": "mfa-token",
            "grantType": "oob",
            "oobCode": "oob-code",
            "bindingCode": "000111"
        ]) { _ in
            XCTAssertEqual(self.spy.verifyOobCodeArg, "oob-code")
            XCTAssertEqual(self.spy.verifyBindingCodeArg, "000111")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testVerifiesWithRecoveryCode() {
        let expectation = self.expectation(description: "Verified with recovery code")
        sut.handle(with: [
            "mfaToken": "mfa-token",
            "grantType": "recovery_code",
            "recoveryCode": "ABCD-EFGH"
        ]) { _ in
            XCTAssertEqual(self.spy.verifyRecoveryCodeArg, "ABCD-EFGH")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesCredentialsOnSuccess() {
        let expectation = self.expectation(description: "Produced credentials")
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "otp", "otp": "123456"]) { result in
            guard let dict = result as? [String: Any] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict[CredentialsProperty.accessToken.rawValue] as? String, "access-token")
            XCTAssertEqual(dict[CredentialsProperty.refreshToken.rawValue] as? String, "refresh-token")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.verifyResult = .failure(MFAVerifyError(info: [:], statusCode: 403))
        sut.handle(with: ["mfaToken": "mfa-token", "grantType": "otp", "otp": "123456"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
