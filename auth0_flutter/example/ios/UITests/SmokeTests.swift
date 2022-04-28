import XCTest

class SmokeTests: XCTestCase {
    private let email = ProcessInfo.processInfo.environment["USER_EMAIL"]!
    private let password = ProcessInfo.processInfo.environment["USER_PASSWORD"]!
    private let loginButton = "Web Auth Login"
    private let logoutButton = "Web Auth Logout"
    private let continueButton = "Continue"
    private let timeout: TimeInterval = 10

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment = ProcessInfo.processInfo.environment
        app.launch()
    }

    func testLogin() {
        tap(button: loginButton)
        let app = XCUIApplication()
        let emailInput = app.webViews.textFields.firstMatch
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: emailInput, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        emailInput.tap()
        emailInput.typeText(email)
        let passwordInput = app.webViews.secureTextFields.firstMatch
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: passwordInput, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        passwordInput.tap()
        passwordInput.typeText(password)
        passwordInput.typeText("\n")
        let webLoginButton = app.webViews.buttons.firstMatch
        expectation(for: NSPredicate(format: "hittable == true"), evaluatedWith: webLoginButton, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
        webLoginButton.tap()
        XCTAssertTrue(app.buttons[logoutButton].waitForExistence(timeout: timeout))
    }

    func testLogout() {
        tap(button: loginButton)
        let app = XCUIApplication()
        let sessionButton = app.webViews.staticTexts[email]
        XCTAssertTrue(sessionButton.waitForExistence(timeout: timeout))
        sessionButton.tap()
        tap(button: logoutButton)
        XCTAssertTrue(app.buttons[loginButton].waitForExistence(timeout: timeout))
    }
}

private extension SmokeTests {
    func tapAlert() {
        let continueButton = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons[continueButton]
        XCTAssertTrue(continueButton.waitForExistence(timeout: timeout))
        continueButton.tap()
    }

    func tap(button label: String) {
        let button = XCUIApplication().buttons[label]
        XCTAssertTrue(button.waitForExistence(timeout: timeout))
        button.tap()
        tapAlert()
    }
}
