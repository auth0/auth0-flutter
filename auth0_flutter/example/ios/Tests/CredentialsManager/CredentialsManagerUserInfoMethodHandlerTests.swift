import XCTest
import Auth0

#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif

@testable import auth0_flutter

class CredentialsManagerUserInfoMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var credentialsManager: CredentialsManager!
    var sut: CredentialsManagerUserInfoMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
        sut = CredentialsManagerUserInfoMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - UserInfo Result

extension CredentialsManagerUserInfoMethodHandlerTests {
    func testCallsCredentialsManagerUserProfileProperty() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testUserInfoIdToken,
                                      refreshToken: "refreshToken",
                                      expiresAt: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Called userProfile property")
        try? credentialsManager.store(credentials: credentials)

        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spyStorage.calledGetEntry)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testReturnsUserInfoDictionaryWhenUserInfoExists() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testUserInfoIdToken,
                                      refreshToken: "refreshToken",
                                      expiresAt: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Returned user info dictionary")
        try? credentialsManager.store(credentials: credentials)

        sut.handle(with: [:]) { result in
            guard let userInfo = result as? [String: Any] else {
                return XCTFail("Expected dictionary but got \(String(describing: result))")
            }

            XCTAssertEqual(userInfo["sub"] as? String, "auth0|user123")
            XCTAssertEqual(userInfo["name"] as? String, "John Doe")
            XCTAssertEqual(userInfo["email"] as? String, "john@example.com")
            XCTAssertEqual(userInfo["nickname"] as? String, "johndoe")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testConvertsAllUserInfoFieldsToDictionaryCorrectly() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testUserInfoIdToken,
                                      refreshToken: "refreshToken",
                                      expiresAt: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Converted all fields correctly")
        try? credentialsManager.store(credentials: credentials)

        sut.handle(with: [:]) { result in
            guard let userInfo = result as? [String: Any] else {
                return XCTFail("Expected dictionary")
            }

            XCTAssertNotNil(userInfo["sub"])
            XCTAssertNotNil(userInfo["name"])
            XCTAssertNotNil(userInfo["email"])
            XCTAssertNotNil(userInfo["nickname"])
            XCTAssertNotNil(userInfo["picture"])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testHandlesUserInfoWithCustomClaims() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testUserInfoIdTokenWithCustomClaims,
                                      refreshToken: "refreshToken",
                                      expiresAt: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let expectation = self.expectation(description: "Handled custom claims")
        try? credentialsManager.store(credentials: credentials)

        sut.handle(with: [:]) { result in
            guard let userInfo = result as? [String: Any] else {
                return XCTFail("Expected dictionary")
            }

            XCTAssertNotNil(userInfo["sub"])

            if let customClaims = userInfo["custom_claims"] as? [String: Any] {
                XCTAssertNotNil(customClaims)
            }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testProducesFlutterErrorWhenNoCredentialsAreStored() {
        let expectation = self.expectation(description: "Produced a FlutterError")
        spyStorage.getEntryReturnValue = nil

        sut.handle(with: [:]) { result in
            XCTAssertTrue(result is FlutterError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Test Helpers

private let testUserInfoIdToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdXRoMHx1c2VyMTIzIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huQGV4YW1wbGUuY29tIiwibmlja25hbWUiOiJqb2huZG9lIiwicGljdHVyZSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vcGljdHVyZS5qcGciLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

private let testUserInfoIdTokenWithCustomClaims = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdXRoMHx1c2VyMTIzIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huQGV4YW1wbGUuY29tIiwicm9sZSI6ImFkbWluIiwiZGVwYXJ0bWVudCI6ImVuZ2luZWVyaW5nIiwiaWF0IjoxNTE2MjM5MDIyfQ.1234567890"
