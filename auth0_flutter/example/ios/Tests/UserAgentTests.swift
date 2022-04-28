import XCTest

@testable import auth0_flutter

class UserAgentTests: XCTestCase {}

// MARK: - Failable Initializer

extension UserAgentTests {
    func testReturnsNilWhenRequiredParametersAreMissing() {
        let parameters: [UserAgentProperty] = [.name, .version]
        parameters.forEach { parameter in
            XCTAssertNil(UserAgent(from: [parameter.rawValue: "foo"]))
        }
    }

    func testReturnsInstanceWhenRequiredParametersArePresent() {
        let parameters = [UserAgentProperty.name.rawValue: "foo", UserAgentProperty.version.rawValue: "bar"]
        XCTAssertNotNil(UserAgent(from: parameters))
    }
}
