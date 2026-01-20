import XCTest
import Auth0

@testable import auth0_flutter

class CredentialsManagerUserInfoMethodHandlerTests: XCTestCase {
    var spyAuthentication: SpyAuthentication!
    var spyStorage: SpyCredentialsStorage!
    var sut: CredentialsManagerUserInfoMethodHandler!

    override func setUpWithError() throws {
        spyAuthentication = SpyAuthentication()
        spyStorage = SpyCredentialsStorage()
        let credentialsManager = CredentialsManager(authentication: spyAuthentication, storage: spyStorage)
        sut = CredentialsManagerUserInfoMethodHandler(credentialsManager: credentialsManager)
    }
}

// MARK: - Method Name

extension CredentialsManagerUserInfoMethodHandlerTests {
    func testHandlesCorrectMethodName() {
        XCTAssertTrue(sut.method == .userInfo)
    }
}

// MARK: - UserInfo Result

extension CredentialsManagerUserInfoMethodHandlerTests {
    func testCallsCredentialsManagerUserInfoProperty() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Called userInfo property")
        spyStorage.getEntryReturnValue = data
        
        sut.handle(with: [:]) { _ in
            XCTAssertTrue(self.spyStorage.calledGetEntry)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testReturnsUserInfoDictionaryWhenUserInfoExists() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Returned user info dictionary")
        spyStorage.getEntryReturnValue = data
        
        sut.handle(with: [:]) { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected success but got error")
            }
            
            guard let userInfo = value as? [String: Any] else {
                return XCTFail("Expected dictionary but got \(type(of: value))")
            }
            
            XCTAssertEqual(userInfo["sub"] as? String, "auth0|user123")
            XCTAssertEqual(userInfo["name"] as? String, "John Doe")
            XCTAssertEqual(userInfo["email"] as? String, "john@example.com")
            XCTAssertEqual(userInfo["nickname"] as? String, "johndoe")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testReturnsNilWhenCredentialsHaveNoUserInfo() {
        let expectation = self.expectation(description: "Returned nil")
        spyStorage.getEntryReturnValue = nil
        
        sut.handle(with: [:]) { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected success but got error")
            }
            
            XCTAssertNil(value)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testConvertsAllUserInfoFieldsToDictionaryCorrectly() {
        let credentials = Credentials(accessToken: "accessToken",
                                      tokenType: "tokenType",
                                      idToken: testIdToken,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Converted all fields correctly")
        spyStorage.getEntryReturnValue = data
        
        sut.handle(with: [:]) { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected success but got error")
            }
            
            guard let userInfo = value as? [String: Any] else {
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
                                      idToken: testIdTokenWithCustomClaims,
                                      refreshToken: "refreshToken",
                                      expiresIn: Date(timeIntervalSinceNow: 3600),
                                      scope: "foo bar")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
        let expectation = self.expectation(description: "Handled custom claims")
        spyStorage.getEntryReturnValue = data
        
        sut.handle(with: [:]) { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected success but got error")
            }
            
            guard let userInfo = value as? [String: Any] else {
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

    func testProducesErrorWhenGetFails() {
        let expectedError = CredentialsManagerError.noCredentials
        let expectation = self.expectation(description: "Produced error")
        spyStorage.getEntryError = expectedError
        
        sut.handle(with: [:]) { result in
            guard case .failure(let error) = result else {
                return XCTFail("Expected error but got success")
            }
            
            XCTAssertTrue(error is CredentialsManagerError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

// MARK: - Test Helpers

private let testIdToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdXRoMHx1c2VyMTIzIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huQGV4YW1wbGUuY29tIiwibmlja25hbWUiOiJqb2huZG9lIiwicGljdHVyZSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vcGljdHVyZS5qcGciLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

private let testIdTokenWithCustomClaims = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhdXRoMHx1c2VyMTIzIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huQGV4YW1wbGUuY29tIiwicm9sZSI6ImFkbWluIiwiZGVwYXJ0bWVudCI6ImVuZ2luZWVyaW5nIiwiaWF0IjoxNTE2MjM5MDIyfQ.1234567890"
