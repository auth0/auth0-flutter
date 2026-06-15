#if PASSKEYS_PLATFORM
import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@available(iOS 16.6, macOS 13.5, visionOS 1.0, *)
class MyAccountEnrollPasskeyMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountEnrollPasskeyMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        let client = SpyMyAccount(spy: spy)
        sut = MyAccountEnrollPasskeyMethodHandler(client: client)
    }

    private func validChallenge() -> [String: Any] {
        return [
            "authenticationMethodId": "passkey|test",
            "authSession": "session123",
            "authParamsPublicKey": [
                "challenge": "Y2hhbGxlbmdl",
                "rpId": "example.com",
                "userId": "dXNlci1pZA",
                "userName": "john@example.com"
            ]
        ]
    }

    private func validCredential() -> [String: Any] {
        return [
            "id": "Y3JlZGVudGlhbA",
            "rawId": "Y3JlZGVudGlhbA",
            "type": "public-key",
            "authenticatorAttachment": "platform",
            "response": [
                "clientDataJSON": "Y2xpZW50RGF0YQ",
                "attestationObject": "YXR0ZXN0YXRpb24"
            ]
        ]
    }

    func testCallsSDKMethod() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: ["challenge": validChallenge(),
                          "credential": validCredential()]) { _ in
            XCTAssertTrue(self.spy.calledEnrollPasskey)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesMethodDictionary() {
        let expectation = self.expectation(description: "Produced passkey method")
        sut.handle(with: ["challenge": validChallenge(),
                          "credential": validCredential()]) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["id"] as? String, "passkey|test")
            XCTAssertEqual(dict["type"] as? String, "passkey")
            XCTAssertEqual(dict["relying_party_id"] as? String, "example.com")
            XCTAssertEqual(dict["credential_device_type"] as? String, "multi_device")
            XCTAssertEqual(dict["credential_backed_up"] as? Bool, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenChallengeMissing() {
        let expectation = self.expectation(description: "Produced FlutterError")
        sut.handle(with: ["credential": validCredential()]) { result in
            XCTAssertTrue(result is FlutterError)
            XCTAssertFalse(self.spy.calledEnrollPasskey)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenCredentialMalformed() {
        let expectation = self.expectation(description: "Produced FlutterError")
        // Missing attestationObject in the response.
        let badCredential: [String: Any] = [
            "id": "Y3JlZGVudGlhbA",
            "rawId": "Y3JlZGVudGlhbA",
            "type": "public-key",
            "response": ["clientDataJSON": "Y2xpZW50RGF0YQ"]
        ]
        sut.handle(with: ["challenge": validChallenge(),
                          "credential": badCredential]) { result in
            XCTAssertTrue(result is FlutterError)
            XCTAssertFalse(self.spy.calledEnrollPasskey)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.enrollPasskeyShouldFail = true
        sut.handle(with: ["challenge": validChallenge(),
                          "credential": validCredential()]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
#endif
