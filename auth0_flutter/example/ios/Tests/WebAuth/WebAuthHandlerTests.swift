import XCTest

@testable import auth0_flutter

class WebAuthHandlerTests: XCTestCase {
    var sut: WebAuthHandler!

    override func setUpWithError() throws {
        sut = WebAuthHandler()
        sut.methodHandlers[.login] = SpyMethodHandler()
        sut.methodHandlers[.logout] = SpyMethodHandler()
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

// MARK: - Required Arguments Error

extension WebAuthHandlerTests {
    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let arguments = ["clientId": self.expectation(description: "clientId is missing"),
                         "domain": self.expectation(description: "domain is missing")]
        for (argument, currentExpectation) in arguments {
            sut.handle(FlutterMethodCall(methodName: "foo", arguments: [argument: "bar"])) { result in
                assertHas(handlerError: .requiredArgumentsMissing, result)
                currentExpectation.fulfill()
            }
        }
        wait(for: Array(arguments.values))
    }

    func testProducesErrorWhenClientIdIsNoString() {
        let arguments: [String: Any] = ["clientId": 1, "domain": "foo"]
        let expectation = self.expectation(description: "clientId is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenDomainIsNoString() {
        let arguments: [String: Any] = ["clientId": "foo", "domain": 1]
        let expectation = self.expectation(description: "domain is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Method Handlers

extension WebAuthHandlerTests {
    func testCallsLoginMethodHandler() {
        let spy = SpyMethodHandler()
        let arguments: [String: Any] = ["clientId": "bar", "domain": "baz"]
        let expectation = self.expectation(description: "Login handler call")
        let methodCall = FlutterMethodCall(methodName: WebAuthHandler.Method.login.rawValue, arguments: arguments)
        sut.methodHandlers[.login] = spy
        sut.handle(methodCall) { _ in
            XCTAssertTrue(spy.argumentsValue == arguments)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testCallsLogoutMethodHandler() {
        let spy = SpyMethodHandler()
        let arguments: [String: Any] = ["clientId": "bar", "domain": "baz"]
        let expectation = self.expectation(description: "Logout handler call")
        let methodCall = FlutterMethodCall(methodName: WebAuthHandler.Method.logout.rawValue, arguments: arguments)
        sut.methodHandlers[.logout] = spy
        sut.handle(methodCall) { _ in
            XCTAssertTrue(spy.argumentsValue == arguments)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
