import XCTest
import Auth0
import JWTDecode

@testable import auth0_flutter

class ExtensionsTests: XCTestCase {}

// MARK: - Auth0Error+details

extension ExtensionsTests {

    // MARK: Cause

    func testReturnsEmptyDetailsWhenErrorIsAuth0ErrorWithNoCause() {
        XCTAssertTrue(MockAuth0Error(debugDescription: "foo").details.isEmpty)
    }

    func testReturnsDetailsWhenErrorIsAuth0ErrorWithCause() {
        let cause = MockError()
        let error = MockAuth0Error(debugDescription: "foo", cause: cause)
        let expected = ["cause": String(describing: cause)]
        XCTAssertTrue(error.details == expected)
    }

    func testReturnsDetailsWhenErrorIsAuth0APIErrorWithNoCause() {
        let error = MockAuth0APIError(info: ["foo": "bar"], statusCode: 0)
        XCTAssertTrue(error.details == error.info)
    }

    func testReturnsDetailsWhenErrorIsAuth0APIErrorWithCause() {
        let cause = MockError()
        let error = MockAuth0APIError(info: [:], statusCode: 0, cause: cause)
        let expected = ["cause": String(describing: cause)]
        XCTAssertTrue(error.details == expected)
    }

    // MARK: Status code

    func testRemovesStatusCodeWhenErrorIsAuth0APIError() {
        let cause = MockError()
        let error = MockAuth0APIError(info: [:], statusCode: 0, cause: cause)
        XCTAssertNil(error.details["statusCode"])
    }
}

// MARK: - Credentials+asDictionary

extension ExtensionsTests {
    func testMapsRequiredCredentialsProperties() {
        let idToken = "eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo"
        let credentials = Credentials(accessToken: "accessToken", idToken: idToken, expiresIn: Date())
        let values = try! credentials.asDictionary()
        XCTAssertEqual(credentials.accessToken, values[CredentialsProperty.accessToken] as? String)
        XCTAssertEqual(credentials.idToken, values[CredentialsProperty.idToken] as? String)
        XCTAssertEqual(credentials.expiresIn.asISO8601String, values[CredentialsProperty.expiresAt] as? String)
        XCTAssertTrue([] == values[CredentialsProperty.scopes] as? [String])
        XCTAssertTrue([:] == values[CredentialsProperty.userProfile] as? [String: Any])
    }

    func testMapsCredentialsRefreshToken() {
        let credentials = Credentials(accessToken: "",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date())
        let values = try! credentials.asDictionary()
        XCTAssertNotNil(credentials.refreshToken)
        XCTAssertEqual(credentials.refreshToken, values[CredentialsProperty.refreshToken] as? String)
    }

    func testMapsCredentialsScope() {
        let credentials = Credentials(accessToken: "", idToken: testIdToken, expiresIn: Date(), scope: "foo bar")
        let values = try! credentials.asDictionary()
        XCTAssertNotNil(credentials.scope)
        XCTAssertEqual(credentials.scope?.split(separator: " ").map(String.init),
                       values[CredentialsProperty.scopes] as? [String])
    }

    func testMapsUserProfile() {
        let credentials = Credentials(accessToken: "", idToken: testIdToken, expiresIn: Date())
        let values = try! credentials.asDictionary()
        let jwt = try! decode(jwt: credentials.idToken)
        let userProfile = UserInfo(json: jwt.body)?.asDictionary()
        XCTAssertTrue(userProfile == values[CredentialsProperty.userProfile] as? [String: Any])
    }
}

// MARK: - UserInfo+asDictionary

extension ExtensionsTests {
    func testMapsRequiredUserInfoProperties() {
        let userInfo = UserInfo(json: [UserInfoProperty.sub.rawValue: "foo"])!
        let values = userInfo.asDictionary()
        XCTAssertEqual(userInfo.sub, values[UserInfoProperty.sub] as? String)
        XCTAssertTrue(values[UserInfoProperty.customClaims] as? [String: Any] == [:])
    }

    func testMapsUserInfoName() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.name.rawValue: "name"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.name)
        XCTAssertEqual(userInfo.name, values[UserInfoProperty.name] as? String)
    }

    func testMapsUserInfoGivenName() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.givenName.rawValue: "givenName"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.givenName)
        XCTAssertEqual(userInfo.givenName, values[UserInfoProperty.givenName] as? String)
    }

    func testMapsUserInfoFamilyName() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.familyName.rawValue: "familyName"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.familyName)
        XCTAssertEqual(userInfo.familyName, values[UserInfoProperty.familyName] as? String)
    }

    func testMapsUserInfoMiddleName() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.middleName.rawValue: "middleName"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.middleName)
        XCTAssertEqual(userInfo.middleName, values[UserInfoProperty.middleName] as? String)
    }

    func testMapsUserInfoNickname() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.nickname.rawValue: "nickname"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.nickname)
        XCTAssertEqual(userInfo.nickname, values[UserInfoProperty.nickname] as? String)
    }

    func testMapsUserInfoPreferredUsername() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.preferredUsername.rawValue: "preferredUsername"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.preferredUsername)
        XCTAssertEqual(userInfo.preferredUsername, values[UserInfoProperty.preferredUsername] as? String)
    }

    func testMapsUserInfoProfile() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.profile.rawValue: "https://example.com/profile"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.profile)
        XCTAssertEqual(userInfo.profile?.absoluteString, values[UserInfoProperty.profile] as? String)
    }

    func testMapsUserInfoPicture() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.picture.rawValue: "https://example.com/picture"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.picture)
        XCTAssertEqual(userInfo.picture?.absoluteString, values[UserInfoProperty.picture] as? String)
    }

    func testMapsUserInfoWebsite() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.website.rawValue: "https://example.com/website"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.website)
        XCTAssertEqual(userInfo.website?.absoluteString, values[UserInfoProperty.website] as? String)
    }

    func testMapsUserInfoEmail() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.email.rawValue: "email"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.email)
        XCTAssertEqual(userInfo.email, values[UserInfoProperty.email] as? String)
    }

    func testMapsUserInfoEmailVerified() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.emailVerified.rawValue: true
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.emailVerified)
        XCTAssertEqual(userInfo.emailVerified, values[UserInfoProperty.emailVerified] as? Bool)
    }

    func testMapsUserInfoGender() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.gender.rawValue: "gender"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.gender)
        XCTAssertEqual(userInfo.gender, values[UserInfoProperty.gender] as? String)
    }

    func testMapsUserInfoBirthdate() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.birthdate.rawValue: "birthdate"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.birthdate)
        XCTAssertEqual(userInfo.birthdate, values[UserInfoProperty.birthdate] as? String)
    }

    func testMapsUserInfoZoneinfo() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.zoneinfo.rawValue: "America/Los_Angeles"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.zoneinfo)
        XCTAssertEqual(userInfo.zoneinfo?.identifier, values[UserInfoProperty.zoneinfo] as? String)
    }

    func testMapsUserInfoLocale() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.locale.rawValue: "en_US"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.locale)
        XCTAssertEqual(userInfo.locale?.identifier, values[UserInfoProperty.locale] as? String)
    }

    func testMapsUserInfoPhoneNumber() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.phoneNumber.rawValue: "phoneNumber"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.phoneNumber)
        XCTAssertEqual(userInfo.phoneNumber, values[UserInfoProperty.phoneNumber] as? String)
    }

    func testMapsUserInfoPhoneNumberVerified() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.phoneNumberVerified.rawValue: true
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.phoneNumberVerified)
        XCTAssertEqual(userInfo.phoneNumberVerified, values[UserInfoProperty.phoneNumberVerified] as? Bool)
    }

    func testMapsUserInfoAddress() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.address.rawValue: ["foo": "bar"] as [String: String]
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.address)
        XCTAssertEqual(userInfo.address, values[UserInfoProperty.address] as? [String: String])
    }

    func testMapsUserInfoUpdatedAt() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.updatedAt.rawValue: "2022-04-15T03:15:51.787Z"
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.updatedAt)
        XCTAssertEqual(userInfo.updatedAt?.asISO8601String, values[UserInfoProperty.updatedAt] as? String)
    }

    func testMapsUserInfoCustomClaims() {
        let data: [String: Any] = [
            UserInfoProperty.sub.rawValue: "",
            UserInfoProperty.customClaims.rawValue: ["foo": "bar"]
        ]
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertNotNil(userInfo.customClaims)
        XCTAssertTrue(userInfo.customClaims == values[UserInfoProperty.customClaims] as? [String: Any])
    }

    func testFiltersUserInfoCustomClaims() {
        let customClaims: [String: Any] = ["foo": "bar"]
        let claims: [String: Any] = [
            "sub": "sub", // Required
            "aud": "aud",
            "iss": "iss",
            "iat": "iat",
            "exp": "exp",
            "nbf": "nbf",
            "nonce": "nonce",
            "azp": "azp",
            "auth_time": "authTime",
            "s_hash": "sHash",
            "at_hash": "atHash",
            "c_hash": "cHash"
        ]
        let data = customClaims.merging(claims) { (first, _) in first }
        let userInfo = UserInfo(json: data)!
        let values = userInfo.asDictionary()
        XCTAssertTrue(values[UserInfoProperty.customClaims] as? [String: Any] == customClaims)
    }
}
