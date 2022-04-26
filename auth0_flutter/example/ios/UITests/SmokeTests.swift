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
        let app = XCUIApplication()
        app.activate()
        tap(button: loginButton)
        let emailInput = app.webViews.textFields.firstMatch
        XCTAssertTrue(emailInput.waitForExistence(timeout: timeout))
        emailInput.tap()
        emailInput.typeText(email)
        let passwordInput = app.webViews.secureTextFields.firstMatch
        passwordInput.tap()
        passwordInput.typeText("\(password)\n")
        app.webViews.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons[logoutButton].waitForExistence(timeout: timeout))
    }

    func testLogout() {
        let app = XCUIApplication()
        app.activate()
        tap(button: loginButton)
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
