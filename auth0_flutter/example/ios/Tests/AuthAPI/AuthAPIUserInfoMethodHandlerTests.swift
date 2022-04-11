
import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPIUserInfoMethodHandlerTests: XCTestCase {
    let spy = SpyAuthentication()
    var sut: AuthAPIUserInfoMethodHandler!

    override func setUpWithError() throws {
        sut = AuthAPIUserInfoMethodHandler(client: spy)
    }
}

// MARK: - Required Arguments Error

extension AuthAPIUserInfoMethodHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let inputs = ["accessToken": self.expectation(description: "accessToken is missing"),
                      "parameters": self.expectation(description: "parameters is missing")]
        for (argument, currentExpectation) in inputs {
            sut.handle(with: arguments(without: argument)) { result in
                assertHas(handlerError: .requiredArgumentsMissing, result)
                currentExpectation.fulfill()
            }
        }
        wait(for: Array(inputs.values))
    }
}

// MARK: - Arguments

extension AuthAPIUserInfoMethodHandlerTests {

    // MARK: accessToken

    func testAddsAccessToken() {
        let key = "accessToken"
        let value = "foo"
        sut.handle(with: arguments(key: key, value: value)) { _ in }
        XCTAssertEqual(spy.arguments[key] as? String, value)
    }
}

// MARK: - UserInfo Result

extension AuthAPIUserInfoMethodHandlerTests {
    func testCallsSDKUserInfoMethod() {
        sut.handle(with: arguments()) { _ in }
        XCTAssertTrue(spy.calledUserInfo)
    }

    func testProducesFullUserProfile() {
        let userInfo = UserInfo(json: [
            "sub": "sub",
            "name": "name",
            "given_name": "givenName",
            "family_name": "familyName",
            "middle_name": "middleName",
            "nickname": "nickName",
            "preferred_username": "preferredUsername",
            "profile": "https://example.com/profile",
            "picture": "https://example.com/picture",
            "website": "https://example.com/website",
            "email": "email",
            "email_verified": true,
            "gender": "gender",
            "birthdate": "birthdate",
            "zoneinfo": "America/Los_Angeles",
            "locale": "en_US",
            "phone_number": "phoneNumber",
            "phone_number_verified": true,
            "address": ["foo": "bar"],
            "updated_at": Date().asISO8601String,
            "custom_claims": ["foo": "bar"]
        ])!
        let expectation = self.expectation(description: "Produced a user profile")
        spy.userInfoResult = .success(userInfo)
        sut.handle(with: arguments()) { result in
            assertHas(userInfo: userInfo, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesUserProfileWithSubOnly() {
        let userInfo = UserInfo(json: ["sub": "foo"])!
        let expectation = self.expectation(description: "Produced a user profile")
        spy.userInfoResult = .success(userInfo)
        sut.handle(with: arguments()) { result in
            assertHas(userInfo: userInfo, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the Authentication error \(error)")
        spy.userInfoResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assertHas(authenticationError: error, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPIUserInfoMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return ["accessToken": "", "parameters": [:]]
    }
}
