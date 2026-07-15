import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MfaEnrollTotpMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: MfaEnrollTotpMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = MfaEnrollTotpMethodHandler(client: spy)
    }

    func testProducesErrorWhenMfaTokenMissing() {
        let expectation = self.expectation(description: "Missing mfaToken")
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testCallsEnrollTotp() {
        let expectation = self.expectation(description: "Called enroll TOTP")
        sut.handle(with: ["mfaToken": "mfa-token"]) { _ in
            XCTAssertTrue(self.spy.calledEnrollTotp)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesChallengeWithSecretOnSuccess() {
        let expectation = self.expectation(description: "Produced TOTP challenge")
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["authenticator_type"] as? String, "otp")
            XCTAssertEqual(dict["totp_secret"] as? String, "SECRET")
            XCTAssertEqual(dict["barcode_uri"] as? String, "otpauth://totp/test")
            XCTAssertEqual(dict["recovery_codes"] as? [String], ["r1"])
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollTotpResult = .failure(MfaEnrollmentError(info: [:], statusCode: 400))
        sut.handle(with: ["mfaToken": "mfa-token"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
