import XCTest

@testable import auth0_flutter

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
        let argument = "clientId"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesErrorWhenDomainIsNoString() {
        let argument = "domain"
        let arguments: [String: Any] = arguments(key: argument, anyValue: 1)
        let expectation = self.expectation(description: "\(argument) is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertHas(handlerError: .requiredArgumentsMissing, result)
            expectation.fulfill()
        }
        wait(for: [expectation])
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

extension WebAuthHandlerTests {
    override func arguments() -> [String: Any] {
        return ["clientId": "foo", "domain": "bar"]
    }
}
