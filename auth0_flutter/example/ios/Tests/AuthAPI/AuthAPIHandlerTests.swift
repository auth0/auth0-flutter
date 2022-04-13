import XCTest

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

// MARK: - Required Arguments Error

extension AuthAPIHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let inputs = ["clientId": self.expectation(description: "clientId is missing"),
                      "domain": self.expectation(description: "domain is missing")]
        for (argument, currentExpectation) in inputs {
            sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments(without: argument))) { result in
                assertHas(handlerError: .requiredArgumentsMissing, result)
                currentExpectation.fulfill()
            }
        }
        wait(for: Array(inputs.values))
    }
}

// MARK: - Method Handlers

extension AuthAPIHandlerTests {
    func testCallsMethodHandlers() {
        var expectations: [XCTestExpectation] = []
        [AuthAPIHandler.Method.loginWithUsernameOrEmail, AuthAPIHandler.Method.signup].forEach { method in
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
        return ["clientId": "foo", "domain": "bar"]
    }
}
