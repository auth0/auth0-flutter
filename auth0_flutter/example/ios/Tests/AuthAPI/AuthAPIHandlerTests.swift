import XCTest

@testable import auth0_flutter

fileprivate typealias Argument = AuthAPIHandler.Argument

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

// MARK: - Required Arguments Error

extension AuthAPIHandlerTests {
    func testProducesErrorWhenArgumentsAreMissing() {
        let expectation = expectation(description: "arguments are missing")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: nil)) { result in
            assertHas(handlerError: .argumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let keys: [Argument] = [.clientId, .domain]
        let expectations = keys.map({ expectation(description: "\($0.rawValue) is missing") })
        for (argument, currentExpectation) in zip(keys, expectations) {
            let methodCall = FlutterMethodCall(methodName: "foo", arguments: arguments(without: argument.rawValue))
            sut.handle(methodCall) { result in
                assertHas(handlerError: .requiredArgumentMissing(argument.rawValue), result)
                currentExpectation.fulfill()
            }
        }
        wait(for: expectations)
    }
}

// MARK: - Method Handlers

extension AuthAPIHandlerTests {
    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        [AuthAPIHandler.Method.loginWithUsernameOrEmail,
         AuthAPIHandler.Method.signup,
         AuthAPIHandler.Method.renewAccessToken,
         AuthAPIHandler.Method.resetPassword].forEach { method in
            let spy = SpyMethodHandler()
            let arguments: [String: Any] = arguments()
            let expectation = self.expectation(description: "\(method.rawValue) handler call")
            expectations.append(expectation)
            let methodCall = FlutterMethodCall(methodName: method.rawValue, arguments: arguments)
            sut.methodHandlers[method] = spy
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
        return [Argument.clientId.rawValue: "foo", Argument.domain.rawValue: "bar"]
    }
}
