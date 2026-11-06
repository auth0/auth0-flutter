#if MY_ACCOUNT_PROFILE
import XCTest
import Auth0

@testable import auth0_flutter

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

class MyAccountGetUserProfileMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountGetUserProfileMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        sut = MyAccountGetUserProfileMethodHandler(client: SpyMyAccount(spy: spy))
    }

    func testCallsSDKMethodWithDefaultOptions() {
        let expectation = self.expectation(description: "Called SDK method")
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spy.calledGetUserProfile)
            XCTAssertNil(self.spy.getUserProfileOptionsArg?.fields)
            XCTAssertEqual(self.spy.getUserProfileOptionsArg?.includeFields, true)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testPassesFieldsAndIncludeFields() {
        let expectation = self.expectation(description: "Passed options")
        let arguments: [String: Any] = ["fields": ["given_name", "profile_policy"], "includeFields": false]
        sut.handle(with: arguments) { _ in
            XCTAssertEqual(self.spy.getUserProfileOptionsArg?.fields, ["given_name", "profile_policy"])
            XCTAssertEqual(self.spy.getUserProfileOptionsArg?.includeFields, false)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesProfileDictionary() {
        let expectation = self.expectation(description: "Produced profile")
        spy.userProfileResult = .success(makeProfile([
            "user_id": "auth0|123",
            "given_name": "Jane",
            "email_verified": true,
            "phone_verified": false,
            "created_at": "2024-01-01T00:00:00.000Z",
            "profile_policy": [
                "/given_name": ["access": "read_only", "source": "idp", "reason": "managed_by_identity_provider"],
                "/nickname": ["access": "something_new", "source": "user"]
            ]
        ]))
        sut.handle(with: [:]) { result in
            guard let profile = result as? [String: Any?] else {
                return XCTFail("Did not produce a dictionary")
            }
            XCTAssertEqual(profile["user_id"] as? String, "auth0|123")
            XCTAssertEqual(profile["given_name"] as? String, "Jane")
            XCTAssertEqual(profile["email_verified"] as? Bool, true)
            XCTAssertEqual(profile["phone_verified"] as? Bool, false)
            XCTAssertEqual(profile["created_at"] as? String, "2024-01-01T00:00:00.000Z")
            XCTAssertNil(profile["family_name"] as? String)

            let policy = profile["profile_policy"] as? [String: [String: Any?]]
            XCTAssertEqual(policy?["/given_name"]?["access"] as? String, "read_only")
            XCTAssertEqual(policy?["/given_name"]?["source"] as? String, "idp")
            XCTAssertEqual(policy?["/given_name"]?["reason"] as? String, "managed_by_identity_provider")
            // Unknown values are forwarded as-is; Dart maps them to null.
            XCTAssertEqual(policy?["/nickname"]?["access"] as? String, "something_new")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesNilProfilePolicyWhenAbsent() {
        let expectation = self.expectation(description: "Produced nil profile_policy")
        spy.userProfileResult = .success(makeProfile(["given_name": "Jane"]))
        sut.handle(with: [:]) { result in
            guard let profile = result as? [String: Any?] else {
                return XCTFail("Did not produce a dictionary")
            }
            XCTAssertNil(profile["profile_policy"] ?? nil)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorWithValidationErrors() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.userProfileResult = .failure(MyAccountError(info: [
            "type": "invalid_request",
            "title": "Bad Request",
            "detail": "Invalid query",
            "validation_errors": [["detail": "unknown field", "field": "fields", "source": "query"]]
        ], statusCode: 400))
        sut.handle(with: [:]) { result in
            guard let error = result as? FlutterError,
                  let details = error.details as? [String: Any] else {
                return XCTFail("Did not produce a FlutterError")
            }
            XCTAssertEqual(details["_statusCode"] as? Int, 400)
            let validationErrors = details["validation_errors"] as? [[String: Any?]]
            XCTAssertEqual(validationErrors?.count, 1)
            XCTAssertEqual(validationErrors?.first?["detail"] as? String, "unknown field")
            XCTAssertEqual(validationErrors?.first?["field"] as? String, "fields")
            XCTAssertEqual(validationErrors?.first?["source"] as? String, "query")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

class MyAccountUpdateUserProfileMethodHandlerTests: XCTestCase {
    var spy: SpyMyAccountAuthenticationMethods!
    var sut: MyAccountUpdateUserProfileMethodHandler!

    override func setUpWithError() throws {
        spy = SpyMyAccountAuthenticationMethods()
        sut = MyAccountUpdateUserProfileMethodHandler(client: SpyMyAccount(spy: spy))
    }

    func testPassesEveryField() {
        let expectation = self.expectation(description: "Passed fields")
        let arguments: [String: Any] = [
            "givenName": "Jane",
            "familyName": "Doe",
            "name": "Jane Doe",
            "nickname": "jane",
            "picture": "https://example.com/jane.png"
        ]
        sut.handle(with: arguments) { _ in
            let request = self.spy.updateUserProfileRequestArg
            XCTAssertTrue(self.spy.calledUpdateUserProfile)
            XCTAssertEqual(request?.givenName, "Jane")
            XCTAssertEqual(request?.familyName, "Doe")
            XCTAssertEqual(request?.name, "Jane Doe")
            XCTAssertEqual(request?.nickname, "jane")
            XCTAssertEqual(request?.picture, "https://example.com/jane.png")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testSendsAnEmptyRequestWhenNoFieldIsProvided() {
        let expectation = self.expectation(description: "Sent empty request")
        sut.handle(with: [:]) { _ in
            let request = self.spy.updateUserProfileRequestArg
            XCTAssertTrue(self.spy.calledUpdateUserProfile)
            XCTAssertNil(request?.givenName)
            XCTAssertNil(request?.familyName)
            XCTAssertNil(request?.name)
            XCTAssertNil(request?.nickname)
            XCTAssertNil(request?.picture)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesProfileDictionary() {
        let expectation = self.expectation(description: "Produced profile")
        spy.userProfileResult = .success(makeProfile(["nickname": "jane"]))
        sut.handle(with: ["nickname": "jane"]) { result in
            guard let profile = result as? [String: Any?] else {
                return XCTFail("Did not produce a dictionary")
            }
            XCTAssertEqual(profile["nickname"] as? String, "jane")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesFlutterErrorOnFailure() {
        let expectation = self.expectation(description: "Produced FlutterError")
        spy.userProfileResult = .failure(MyAccountError(info: [:], statusCode: 403))
        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
#endif
