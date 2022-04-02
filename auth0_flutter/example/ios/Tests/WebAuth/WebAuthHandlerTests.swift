import XCTest
import Flutter

@testable import auth0_flutter

class WebAuthHandlerTests: XCTestCase {
    var sut: WebAuthHandler!

    override func setUpWithError() throws {
        sut = WebAuthHandler()
        sut.loginMethodHandler = MockMethodHandler()
        sut.logoutMethodHandler = MockMethodHandler()
    }

    // MARK: - Registration

    func testRegistersItself() {
        let spy = SpyPluginRegistrar()
        WebAuthHandler.register(with: spy)
        XCTAssertTrue(spy.delegate is WebAuthHandler)
    }

    // MARK: - Required Arguments

    func testProducesErrorWhenRequiredArgumentsAreMissing() {
        let arguments = ["clientId": self.expectation(description: "clientId is missing"),
                         "domain": self.expectation(description: "domain is missing")]
        for (argument, currentExpectation) in arguments {
            sut.handle(FlutterMethodCall(methodName: "foo", arguments: [argument: "bar"])) { result in
                assertRequiredArgumentsError(result)
                currentExpectation.fulfill()
            }
        }
        wait(for: Array(arguments.values), timeout: timeout)
    }

    func testProducesErrorWhenClientIdIsNoString() {
        let arguments: [String: Any] = ["clientId": 1, "domain": "foo"]
        let expectation = self.expectation(description: "clientId is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertRequiredArgumentsError(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testProducesErrorWhenDomainIsNoString() {
        let arguments: [String: Any] = ["clientId": "foo", "domain": 1]
        let expectation = self.expectation(description: "domain is not a string")
        sut.handle(FlutterMethodCall(methodName: "foo", arguments: arguments)) { result in
            assertRequiredArgumentsError(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    // MARK: - Method Handlers

    func testCallsLoginMethodHandler() {
        let spy = SpyMethodHandler()
        let arguments: [String: Any] = ["clientId": "bar", "domain": "baz"]
        let expectation = self.expectation(description: "Login handler call")
        let methodCall = FlutterMethodCall(methodName: WebAuthHandler.Method.login.rawValue, arguments: arguments)
        sut.loginMethodHandler = spy
        sut.handle(methodCall) { _ in
            XCTAssertTrue(NSDictionary(dictionary: spy.argumentsValue).isEqual(to: arguments))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }

    func testCallsLogoutMethodHandler() {
        let spy = SpyMethodHandler()
        let arguments: [String: Any] = ["clientId": "bar", "domain": "baz"]
        let expectation = self.expectation(description: "Logout handler call")
        let methodCall = FlutterMethodCall(methodName: WebAuthHandler.Method.logout.rawValue, arguments: arguments)
        sut.logoutMethodHandler = spy
        sut.handle(methodCall) { _ in
            XCTAssertTrue(NSDictionary(dictionary: spy.argumentsValue).isEqual(to: arguments))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: timeout)
    }
}
