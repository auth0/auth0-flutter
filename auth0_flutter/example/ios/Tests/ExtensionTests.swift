import XCTest
import Auth0

@testable import auth0_flutter

class ExtensionTests: XCTestCase {

    // MARK: Auth0Error+details

    func testReturnsNilWhenErrorIsAuth0ErrorWithNoCause() {
        XCTAssertNil(MockAuth0Error(debugDescription: "foo").details)
    }

    func testReturnsDictionaryWhenErrorIsAuth0ErrorWithCause() {
        let cause = MockError()
        let error = MockAuth0Error(debugDescription: "foo", cause: cause)
        let expected = ["cause": String(describing: cause)]
        XCTAssertNotNil(error.details)
        XCTAssertTrue(NSDictionary(dictionary: error.details!).isEqual(to: expected))
    }

    func testReturnsInfoWhenErrorIsAuth0APIErrorWithNoCause() {
        let error = MockAuth0APIError(info: ["foo": "bar"], statusCode: 0)
        XCTAssertNotNil(error.details)
        XCTAssertTrue(NSDictionary(dictionary: error.details!).isEqual(to: error.info))
    }

    func testReturnsInfoWhenErrorIsAuth0APIErrorWithCause() {
        let cause = MockError()
        let error = MockAuth0APIError(info: [:], statusCode: 0, cause: cause)
        let expected = ["cause": String(describing: cause)]
        XCTAssertNotNil(error.details)
        XCTAssertTrue(NSDictionary(dictionary: error.details!).isEqual(to: expected))
    }
}
