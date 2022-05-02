import XCTest
import Auth0

@testable import auth0_flutter

class AuthAPIHandlerTests: XCTestCase {
    var sut: AuthAPIHandler!

    override func setUpWithError() throws {
        sut = AuthAPIHandler()
    }
}

// MARK: - Registration

extension AuthAPIHandlerTests {
    func testRegistersItself() {
        let spy = SpyPluginRegistrar()
        AuthAPIHandler.register(with: spy)
        XCTAssertTrue(spy.delegate is AuthAPIHandler)
    }
}

// MARK: - Required Arguments

extension AuthAPIHandlerTests {
    func testProducesErrorWhenArgumentsAreMissing() {
        let expectation = expectation(description: "arguments are missing")
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

// MARK: - Providers

extension AuthAPIHandlerTests {

    // MARK: AuthAPIClientProvider

    func testCallsClientProvider() {
        let methodName = AuthAPIHandler.Method.loginWithUsernameOrEmail.rawValue
        let accountDictionary = [AccountProperty.clientId.rawValue: "foo", AccountProperty.domain.rawValue: "bar"]
        let userAgentDictionary = [UserAgentProperty.name.rawValue: "baz", UserAgentProperty.version.rawValue: "qux"]
        let argumentsDictionary = [Account.key: accountDictionary, UserAgent.key: userAgentDictionary]
        let expectation = self.expectation(description: "called client provider")
        sut.clientProvider = { account, userAgent in
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

    // MARK: AuthAPIMethodHandlerProvider

    func testCallsMethodHandlerProvider() {
        let methodName = AuthAPIHandler.Method.loginWithUsernameOrEmail.rawValue
        let expectation = self.expectation(description: "called method handler provider")
        sut.methodHandlerProvider = { method, _ in
            XCTAssertTrue(method.rawValue == methodName)
            expectation.fulfill()
            return SpyMethodHandler()
        }
        sut.handle(FlutterMethodCall(methodName: methodName, arguments: arguments())) { _ in }
        wait(for: [expectation])
    }

    func testDoesNotCallMethodHandlerProviderWhenMethodIsUnsupported() {
        let expectation = self.expectation(description: "did not call method handler provider")
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

    func testReturnsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        let methodHandlers: [AuthAPIHandler.Method: MethodHandler.Type] = [
            .loginWithUsernameOrEmail: AuthAPILoginUsernameOrEmailMethodHandler.self,
            .signup: AuthAPISignupMethodHandler.self,
            .userInfo: AuthAPIUserInfoMethodHandler.self,
            .renew: AuthAPIRenewMethodHandler.self,
            .resetPassword: AuthAPIResetPasswordMethodHandler.self
        ]
        methodHandlers.forEach { method, methodHandler in
            let methodCall = FlutterMethodCall(methodName: method.rawValue, arguments: arguments())
            let expectation = self.expectation(description: "returned \(methodHandler)")
            expectations.append(expectation)
            sut.methodHandlerProvider = { method, client in
                let result = AuthAPIHandler().methodHandlerProvider(method, client)
                XCTAssertTrue(type(of: result) == methodHandler)
                expectation.fulfill()
                return result
            }
            sut.handle(methodCall) { _ in }
        }
        wait(for: expectations)
    }
}

// MARK: - Method Handlers

extension AuthAPIHandlerTests {
    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        AuthAPIHandler.Method.allCases.forEach { method in
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

extension AuthAPIHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Account.key: [AccountProperty.clientId.rawValue: "", AccountProperty.domain.rawValue: ""],
            UserAgent.key: [UserAgentProperty.name.rawValue: "", UserAgentProperty.version.rawValue: ""]
        ]
    }
}
