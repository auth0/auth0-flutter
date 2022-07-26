import XCTest

@testable import Auth0
@testable import auth0_flutter

class CredentialsManagerHandlerTests: XCTestCase {
    var sut: CredentialsManagerHandler!

    override func setUpWithError() throws {
        sut = CredentialsManagerHandler()
    }
}

// MARK: - Registration

extension CredentialsManagerHandlerTests {
    func testRegistersItself() {
        let spy = SpyPluginRegistrar()
        CredentialsManagerHandler.register(with: spy)
        XCTAssertTrue(spy.delegate is CredentialsManagerHandler)
    }
}

// MARK: - Required Arguments

extension CredentialsManagerHandlerTests {
    func testProducesErrorWhenArgumentsAreMissing() {
        let expectation = expectation(description: "Arguments are missing")
        sut.handle(FlutterMethodCall(methodName: "", arguments: nil)) { result in
            assert(result: result, isError: .argumentsMissing)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenAccountIsMissing() {
        let expectation = expectation(description: "account is missing")
        sut.handle(FlutterMethodCall(methodName: "", arguments: arguments(without: Account.key))) { result in
            assert(result: result, isError: .accountMissing)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenUserAgentIsMissing() {
        let expectation = expectation(description: "userAgent is missing")
        sut.handle(FlutterMethodCall(methodName: "", arguments: arguments(without: UserAgent.key))) { result in
            assert(result: result, isError: .userAgentMissing)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Arguments

extension CredentialsManagerHandlerTests {

    // MARK: title (local authentication)

    func testUsesDefaultLocalAuthenticationTitle() {
        let expectation = expectation(description: "Default local authentication title is used")
        var credentialsManager: CredentialsManager?
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [:]
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))) { _ in
            XCTAssertEqual(credentialsManager?.bioAuth?.title, "Please authenticate to continue")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testSetsLocalAuthenticationTitle() {
        let expectation = expectation(description: "Local authentication title is set")
        var credentialsManager: CredentialsManager?
        let title = "foo"
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [LocalAuthenticationProperty.title.rawValue: title]
        let methodCall = FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(methodCall) { _ in
            XCTAssertEqual(credentialsManager?.bioAuth?.title, title)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: cancelTitle (local authentication)

    func testAddsCancelTitle() {
        let expectation = expectation(description: "Local authentication cancelTitle is added")
        var credentialsManager: CredentialsManager?
        let cancelTitle = "foo"
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [
            LocalAuthenticationProperty.title.rawValue: "",
            LocalAuthenticationProperty.cancelTitle.rawValue: cancelTitle
        ]
        let methodCall = FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(methodCall) { _ in
            XCTAssertEqual(credentialsManager?.bioAuth?.cancelTitle, cancelTitle)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testDoesNotAddCancelTitleWhenNil() {
        let expectation = expectation(description: "Local authentication cancelTitle is not added")
        var credentialsManager: CredentialsManager?
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [LocalAuthenticationProperty.title.rawValue: ""]
        let methodCall = FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(methodCall) { _ in
            XCTAssertNotNil(credentialsManager?.bioAuth)
            XCTAssertNil(credentialsManager?.bioAuth?.cancelTitle)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    // MARK: fallbackTitle (local authentication)

    func testAddsFallbackTitle() {
        let expectation = expectation(description: "Local authentication fallbackTitle is added")
        var credentialsManager: CredentialsManager?
        let fallbackTitle = "foo"
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [
            LocalAuthenticationProperty.title.rawValue: "",
            LocalAuthenticationProperty.fallbackTitle.rawValue: fallbackTitle
        ]
        let methodCall = FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(methodCall) { _ in
            XCTAssertNotNil(credentialsManager?.bioAuth)
            XCTAssertEqual(credentialsManager?.bioAuth?.fallbackTitle, fallbackTitle)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testDoesNotAddFallbackTitleWhenNil() {
        let expectation = expectation(description: "Local authentication fallbackTitle is not added")
        var credentialsManager: CredentialsManager?
        let method = CredentialsManagerHandler.Method.save.rawValue
        let key = LocalAuthentication.key
        let value: [String: String?] = [LocalAuthenticationProperty.title.rawValue: ""]
        let methodCall = FlutterMethodCall(methodName: method, arguments: arguments(withKey: key, value: value))
        sut.methodHandlerProvider = { _, instance in
            credentialsManager = instance
            return SpyMethodHandler()
        }
        sut.handle(methodCall) { _ in
            XCTAssertNotNil(credentialsManager?.bioAuth)
            XCTAssertNil(credentialsManager?.bioAuth?.fallbackTitle)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Providers

extension CredentialsManagerHandlerTests {

    // MARK: AuthAPIClientProvider

    func testCallsAPIClientProvider() {
        let methodName = CredentialsManagerHandler.Method.save.rawValue
        let accountDictionary = [AccountProperty.clientId.rawValue: "foo", AccountProperty.domain.rawValue: "bar"]
        let userAgentDictionary = [UserAgentProperty.name.rawValue: "baz", UserAgentProperty.version.rawValue: "qux"]
        let argumentsDictionary = [Account.key: accountDictionary, UserAgent.key: userAgentDictionary]
        let expectation = self.expectation(description: "Called API client provider")
        sut.apiClientProvider = { account, userAgent in
            XCTAssertEqual(account.clientId, accountDictionary[AccountProperty.clientId])
            XCTAssertEqual(account.domain, accountDictionary[AccountProperty.domain])
            XCTAssertEqual(userAgent.name, userAgentDictionary[UserAgentProperty.name])
            XCTAssertEqual(userAgent.version, userAgentDictionary[UserAgentProperty.version])
            expectation.fulfill()
            return SpyAuthentication()
        }
        sut.handle(FlutterMethodCall(methodName: methodName, arguments: argumentsDictionary)) { _ in }
        wait(for: [expectation])
    }

    // MARK: CredentialsManagerProvider

    func testCallsCredentialsManagerProvider() {
        let methodName = CredentialsManagerHandler.Method.save.rawValue
        let expectation = self.expectation(description: "Called credentials manager provider")
        sut.apiClientProvider = { _, _ in
            return SpyAuthentication()
        }
        sut.credentialsManagerProvider = { _, _ in
            expectation.fulfill()
            return CredentialsManager(authentication: SpyAuthentication())
        }
        sut.handle(FlutterMethodCall(methodName: methodName, arguments: arguments())) { _ in }
        wait(for: [expectation])
    }

    // MARK: CredentialsManagerMethodHandlerProvider

    func testCallsMethodHandlerProvider() {
        let methodName = CredentialsManagerHandler.Method.save.rawValue
        let expectation = self.expectation(description: "Called method handler provider")
        sut.methodHandlerProvider = { method, _ in
            XCTAssertTrue(method.rawValue == methodName)
            expectation.fulfill()
            return SpyMethodHandler()
        }
        sut.handle(FlutterMethodCall(methodName: methodName, arguments: arguments())) { _ in }
        wait(for: [expectation])
    }

    func testDoesNotCallMethodHandlerProviderWhenMethodIsUnsupported() {
        let expectation = self.expectation(description: "Did not call method handler provider")
        sut.methodHandlerProvider = { _, _ in
            XCTFail("called method handler provider")
            return SpyMethodHandler()
        }
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments())) { result in
            XCTAssertEqual(result as? NSObject, FlutterMethodNotImplemented)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Method Handlers

extension CredentialsManagerHandlerTests {
    func testReturnsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        let methodHandlers: [CredentialsManagerHandler.Method: MethodHandler.Type] = [
            .save: CredentialsManagerSaveMethodHandler.self,
            .hasValid: CredentialsManagerHasValidMethodHandler.self,
            .get: CredentialsManagerGetMethodHandler.self,
            .clear: CredentialsManagerClearMethodHandler.self
        ]
        methodHandlers.forEach { method, methodHandler in
            let methodCall = FlutterMethodCall(methodName: method.rawValue, arguments: arguments())
            let expectation = self.expectation(description: "Returned \(methodHandler)")
            expectations.append(expectation)
            sut.methodHandlerProvider = { method, client in
                let result = CredentialsManagerHandler().methodHandlerProvider(method, client)
                XCTAssertTrue(type(of: result) == methodHandler)
                expectation.fulfill()
                return result
            }
            sut.handle(methodCall) { _ in }
        }
        wait(for: expectations)
    }

    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        CredentialsManagerHandler.Method.allCases.forEach { method in
            let arguments: [String: Any] = arguments()
            let expectation = self.expectation(description: "\(method.rawValue) handler call")
            expectations.append(expectation)
            let methodCall = FlutterMethodCall(methodName: method.rawValue, arguments: arguments)
            let spy = SpyMethodHandler()
            sut.methodHandlerProvider = { _, _ in
                return spy
            }
            sut.handle(methodCall) { _ in
                XCTAssertTrue(spy.argumentsValue == arguments)
                expectation.fulfill()
            }
        }
        wait(for: expectations)
    }
}

// MARK: - Helpers

extension CredentialsManagerHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Account.key: [AccountProperty.clientId.rawValue: "", AccountProperty.domain.rawValue: ""],
            UserAgent.key: [UserAgentProperty.name.rawValue: "", UserAgentProperty.version.rawValue: ""]
        ]
    }
}
