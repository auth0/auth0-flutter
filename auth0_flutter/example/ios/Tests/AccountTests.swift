import XCTest

@testable import auth0_flutter

class AccountTests: XCTestCase {}

// MARK: - Failable Initializer

extension AccountTests {
    func testReturnsNilWhenRequiredParametersAreMissing() {
        let parameters: [AccountProperty] = [.clientId, .domain]
        parameters.forEach { parameter in
            XCTAssertNil(Account(from: [parameter.rawValue: "foo"]))
        }
    }

    func testReturnsInstanceWhenRequiredParametersArePresent() {
        let parameters = [AccountProperty.clientId.rawValue: "foo", AccountProperty.domain.rawValue: "bar"]
        XCTAssertNotNil(Account(from: parameters))
    }
}
