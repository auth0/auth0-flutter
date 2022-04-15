
import XCTest
import Auth0

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIUserInfoMethodHandler.Argument

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
        let key = Argument.accessToken
        let expectation = expectation(description: "\(key.rawValue) is missing")
        sut.handle(with: arguments(without: key)) { result in
            assert(result: result, isError: .requiredArgumentMissing(key.rawValue))
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension AuthAPIUserInfoMethodHandlerTests {

    // MARK: accessToken

    func testAddsAccessToken() {
        let key = Argument.accessToken
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

    func testProducesUserProfile() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "sub",
            UserInfoProperty.name.rawValue: "name",
            UserInfoProperty.givenName.rawValue: "givenName",
            UserInfoProperty.familyName.rawValue: "familyName",
            UserInfoProperty.middleName.rawValue: "middleName",
            UserInfoProperty.nickname.rawValue: "nickName",
            UserInfoProperty.preferredUsername.rawValue: "preferredUsername",
            UserInfoProperty.profile.rawValue: "https://example.com/profile",
            UserInfoProperty.picture.rawValue: "https://example.com/picture",
            UserInfoProperty.website.rawValue: "https://example.com/website",
            UserInfoProperty.email.rawValue: "email",
            UserInfoProperty.emailVerified.rawValue: true,
            UserInfoProperty.gender.rawValue: "gender",
            UserInfoProperty.birthdate.rawValue: "birthdate",
            UserInfoProperty.zoneinfo.rawValue: "America/Los_Angeles",
            UserInfoProperty.locale.rawValue: "en_US",
            UserInfoProperty.phoneNumber.rawValue: "phoneNumber",
            UserInfoProperty.phoneNumberVerified.rawValue: true,
            UserInfoProperty.address.rawValue: ["foo": "bar"],
            UserInfoProperty.updatedAt.rawValue: "2022-04-15T03:15:51.787Z",
            UserInfoProperty.customClaims.rawValue: ["foo": "bar"]
        ]
        let userInfo = UserInfo(json: data)!
        let expectation = self.expectation(description: "Produced a user profile")
        spy.userInfoResult = .success(userInfo)
        sut.handle(with: arguments()) { result in
            assert(result: result, has: UserInfoProperty.allCases)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesAuthenticationError() {
        let error = AuthenticationError(info: [:], statusCode: 0)
        let expectation = self.expectation(description: "Produced the AuthenticationError \(error)")
        spy.userInfoResult = .failure(error)
        sut.handle(with: arguments()) { result in
            assert(result: result, isError: error)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Helpers

extension AuthAPIUserInfoMethodHandlerTests {
    override func arguments() -> [String: Any] {
        return [Argument.accessToken.rawValue: ""]
    }
}
