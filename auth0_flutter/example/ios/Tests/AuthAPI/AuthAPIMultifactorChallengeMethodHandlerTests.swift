import XCTest

@testable import Auth0
@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIMultifactorChallengeMethodHandler.Argument

class AuthAPIMultifactorChallengeMethodHandlerTests: XCTestCase {
    var spy: SpyAuthentication!
    var sut: AuthAPIMultifactorChallengeMethodHandler!

    override func setUpWithError() throws {
        spy = SpyAuthentication()
        sut = AuthAPIMultifactorChallengeMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPIMultifactorChallengeMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.mfaToken, .parameters]
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

// MARK: - Arguments

extension AuthAPIMultifactorChallengeMethodHandlerTests {

    // MARK: mfaToken

    func testAddsMFAToken() {
        let key = Argument.mfaToken
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    // MARK: types

    func testAddsTypes() {
        let key = Argument.types
        let value = ["foo"]
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? [String], value)
    }

    func testDoesNotAddTypesWhenNil() {
        let argument = Argument.types
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument])
    }

    // MARK: authenticatorId

    func testAddsAuthenticatorId() {
        let key = Argument.authenticatorId
        let value = "foo"
        sut.handle(with: arguments(withKey: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }

    func testDoesNotAddAuthenticatorIdWhenNil() {
        let argument = Argument.authenticatorId
        sut.handle(with: arguments(without: argument)) { _ in }
        XCTAssertNil(spy.arguments[argument])
    }
}

// MARK: - Multifactor Challenge Result

extension AuthAPIMultifactorChallengeMethodHandlerTests {
    func testCallsSDKMultifactorChallengeMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledMultifactorChallenge)
    }

    func testProducesChallenge() {
        let challenge = Challenge(challengeType: "foo", oobCode: "bar", bindingMethod: "baz")
        let expectation = self.expectation(description: "Produced a challenge")
        spy.challengeResult = .success(challenge)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: challenge)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.challengeResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
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
            Argument.types.rawValue: [],
            Argument.authenticatorId.rawValue: "",
            Argument.parameters.rawValue: [:]
        ]
    }
}
