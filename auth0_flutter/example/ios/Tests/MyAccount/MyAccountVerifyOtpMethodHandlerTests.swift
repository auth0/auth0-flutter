import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountVerifyOtpMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountVerifyOtpMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountVerifyOtpMethodHandler(client: client)
    }

    func testProducesErrorWhenIdMissing() {
        let expectation = self.expectation(description: "Missing id")
        sut.handle(with: ["authSession": "session", "otp": "123456", "factorType": "phone"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthSessionMissing() {
        let expectation = self.expectation(description: "Missing authSession")
        sut.handle(with: ["id": "test-id", "otp": "123456", "factorType": "phone"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenOtpMissing() {
        let expectation = self.expectation(description: "Missing otp")
        sut.handle(with: ["id": "test-id", "authSession": "session", "factorType": "phone"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenFactorTypeMissing() {
        let expectation = self.expectation(description: "Missing factorType")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesArgumentsToSDK() {
        let expectation = self.expectation(description: "Arguments passed to SDK")
        sut.handle(with: ["id": "test-id", "authSession": "session123", "otp": "654321", "factorType": "phone"]) { _ in
            XCTAssertEqual(self.spy.confirmIdArg, "test-id")
            XCTAssertEqual(self.spy.confirmAuthSessionArg, "session123")
            XCTAssertEqual(self.spy.confirmOtpArg, "654321")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testRoutesToPhoneEnrollmentByDefault() {
        let expectation = self.expectation(description: "Routes to phone enrollment")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456", "factorType": "phone"]) { _ in
            XCTAssertEqual(self.spy.confirmEnrollmentFactorType, "phone")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testRoutesToEmailEnrollment() {
        let expectation = self.expectation(description: "Routes to email enrollment")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456", "factorType": "email"]) { _ in
            XCTAssertEqual(self.spy.confirmEnrollmentFactorType, "email")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testRoutesToTOTPEnrollment() {
        let expectation = self.expectation(description: "Routes to TOTP enrollment")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456", "factorType": "totp"]) { _ in
            XCTAssertEqual(self.spy.confirmEnrollmentFactorType, "totp")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesDictionaryOnSuccess() {
        let expectation = self.expectation(description: "Produced dictionary")
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "123456", "factorType": "phone"]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "test-id")
            XCTAssertEqual(dict["confirmed"] as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.confirmResult = .failure(MyAccountError(info: [:], statusCode: 403))
        sut.handle(with: ["id": "test-id", "authSession": "session", "otp": "wrong", "factorType": "phone"]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
