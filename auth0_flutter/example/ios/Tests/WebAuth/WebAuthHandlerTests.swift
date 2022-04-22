import XCTest
import Auth0

@testable import auth0_flutter

fileprivate class SpySUT: WebAuthHandler {
    private(set) var accountValue: Account?
    private(set) var userAgentValue: UserAgent?

    override func makeClient(account: Account, userAgent: UserAgent) -> WebAuth {
        accountValue = account
        userAgentValue = userAgent

        return SpyWebAuth()
    }
}

class WebAuthHandlerTests: XCTestCase {
    var sut: WebAuthHandler!

    override func setUpWithError() throws {
        sut = WebAuthHandler()
    }
}

// MARK: - Registration

extension WebAuthHandlerTests {
    func testRegistersItself() {
        let spy = SpyPluginRegistrar()
        WebAuthHandler.register(with: spy)
        XCTAssertTrue(spy.delegate is WebAuthHandler)
    }
}

// MARK: - Required Arguments

extension WebAuthHandlerTests {
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

extension WebAuthHandlerTests {
    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        WebAuthHandler.Method.allCases.forEach { method in
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

extension WebAuthHandlerTests {
    override func arguments() -> [String: Any] {
        return [
            Account.key: [AccountProperty.clientId.rawValue: "", AccountProperty.domain.rawValue: ""],
            UserAgent.key: [UserAgentProperty.name.rawValue: "", UserAgentProperty.version.rawValue: ""]
        ]
    }
}
