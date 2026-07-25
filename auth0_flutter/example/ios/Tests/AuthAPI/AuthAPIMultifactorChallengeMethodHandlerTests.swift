import XCTest

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import Auth0
@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIMultifactorChallengeMethodHandler.Argument

class AuthAPIMultifactorChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyMFAClient!
    var sut: AuthAPIMultifactorChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMFAClient()
        sut = AuthAPIMultifactorChallengeMethodHandler(client: spy)
    }
}

// MARK: - Required Argument Error

extension AuthAPIMultifactorChallengeMethodHandlerTests {
    func testProducesErrorWhenMFATokenIsMissing() {
        let key = Argument.mfaToken
        let expectation = self.expectation(description: "mfaToken is missing")
        sut.handle(with: arguments(without: key)) { result in
            assert(result: result, isError: .requiredArgumentMissing(key.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAuthenticatorIdIsMissing() {
        let key = Argument.authenticatorId
        let expectation = self.expectation(description: "authenticatorId is missing")
        sut.handle(with: arguments(without: key)) { result in
            assert(result: result, isError: .requiredArgumentMissing(key.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension AuthAPIMultifactorChallengeMethodHandlerTests {

    // MARK: authenticatorId

    func testAddsAuthenticatorId() {
        let value = "foo"
        sut.handle(with: arguments(withKey: Argument.authenticatorId, value: value)) { _ in }
        XCTAssertEqual(spy.challengeAuthenticatorIdArg, value)
    }
}

// MARK: - Multifactor Challenge Result

extension AuthAPIMultifactorChallengeMethodHandlerTests {
    func testCallsSDKChallengeMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledChallenge)
    }

    func testProducesChallenge() {
        let challenge = MFAChallenge(challengeType: "foo", oobCode: "bar", bindingMethod: "baz")
        let expectation = self.expectation(description: "Produced a challenge")
        spy.challengeResult = .success(challenge)
        sut.handle(with: arguments()) { result in
            guard let dict = result as? [String: Any?] else {
                return XCTFail("Did not produce dictionary")
            }
            XCTAssertEqual(dict["challengeType"] as? String, challenge.challengeType)
            XCTAssertEqual(dict["oobCode"] as? String, challenge.oobCode)
            XCTAssertEqual(dict["bindingMethod"] as? String, challenge.bindingMethod)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesMfaChallengeError() {
        let error = MfaChallengeError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the MfaChallengeError \(error)")
        spy.challengeResult = .failure(error)
        sut.handle(with: arguments()) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPIMultifactorChallengeMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Argument.mfaToken.rawValue: "",
            Argument.authenticatorId.rawValue: ""
        ]
    }
}
