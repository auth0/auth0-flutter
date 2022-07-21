import XCTest

@testable import auth0_flutter

class ModelsTests: XCTestCase {}

// MARK: - Account

extension ModelsTests {
    func testReturnsNilAccountWhenRequiredParametersAreMissing() {
        let parameters: [AccountProperty] = [.clientId, .domain]
        parameters.forEach { parameter in
            XCTAssertNil(Account(from: [parameter.rawValue: "foo"]))
        }
    }

    func testReturnsAccountInstanceWhenRequiredParametersArePresent() {
        let parameters = [AccountProperty.clientId.rawValue: "foo", AccountProperty.domain.rawValue: "bar"]
        XCTAssertNotNil(Account(from: parameters))
    }
}

// MARK: - UserAgent

extension ModelsTests {
    func testReturnsNilUserAgentWhenRequiredParametersAreMissing() {
        let parameters: [UserAgentProperty] = [.name, .version]
        parameters.forEach { parameter in
            XCTAssertNil(UserAgent(from: [parameter.rawValue: "foo"]))
        }
    }

    func testReturnsUserAgentInstanceWhenRequiredParametersArePresent() {
        let parameters = [UserAgentProperty.name.rawValue: "foo", UserAgentProperty.version.rawValue: "bar"]
        XCTAssertNotNil(UserAgent(from: parameters))
    }
}
