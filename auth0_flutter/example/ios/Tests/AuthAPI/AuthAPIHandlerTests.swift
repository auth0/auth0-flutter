import XCTest
import Auth0

@testable import auth0_flutter

fileprivate class SpySUT: AuthAPIHandler {
    private(set) var accountValue: Account?
    private(set) var userAgentValue: UserAgent?

    override func makeClient(account: Account, userAgent: UserAgent) -> Authentication {
        accountValue = account
        userAgentValue = userAgent

        return SpyAuthentication()
    }
}

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

    func testMakesClientWithRequiredArguments() {
        let account = [AccountProperty.clientId.rawValue: "foo", AccountProperty.domain.rawValue: "bar"]
        let userAgent = [UserAgentProperty.name.rawValue: "baz", UserAgentProperty.version.rawValue: "qux"]
        let argumentsDictionary = [Account.key: account, UserAgent.key: userAgent]
        let sut = SpySUT()
        sut.handle(FlutterMethodCall(methodName: "", arguments: argumentsDictionary)) { _ in }
        XCTAssertEqual(sut.accountValue?.clientId, account[AccountProperty.clientId])
        XCTAssertEqual(sut.accountValue?.domain, account[AccountProperty.domain])
        XCTAssertEqual(sut.userAgentValue?.name, userAgent[UserAgentProperty.name])
        XCTAssertEqual(sut.userAgentValue?.version, userAgent[UserAgentProperty.version])
    }
}

// MARK: - Method Handlers

extension AuthAPIHandlerTests {
    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        AuthAPIHandler.Method.allCases.forEach { method in
            let spy = SpyMethodHandler()
            let arguments: [String: Any] = arguments()
            let expectation = self.expectation(description: "\(method.rawValue) handler call")
            expectations.append(expectation)
            let methodCall = FlutterMethodCall(methodName: method.rawValue, arguments: arguments)
            sut.methodHandler = spy
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
