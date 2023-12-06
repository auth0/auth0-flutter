import XCTest

class SmokeTests: XCTestCase {
    private let email = ProcessInfo.processInfo.environment["USER_EMAIL"]!
    private let password = ProcessInfo.processInfo.environment["USER_PASSWORD"]!
    private let loginButton = "Web Auth Login"
    private let logoutButton = "Web Auth Logout"
    private let continueButton = "Continue"
    private let webLoginButton = "Log In"
    private let browserApp = "com.apple.Safari"
    private let appView = "example"
    private let timeout: TimeInterval = 30

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("--smoke-tests")
        app.launchEnvironment = ProcessInfo.processInfo.environment
        app.launch()
    }

    func testLogin() {
        let app = XCUIApplication()
        app.activate()

        let view = app.windows.firstMatch.groups[appView]
        view.click()

        clickAlert()

        let browser = XCUIApplication(bundleIdentifier: browserApp)
        let browserWindow = browser
            .windows
            .firstMatch
            .webViews
            .firstMatch
        XCTAssertTrue(browserWindow.waitForExistence(timeout: timeout))

        let emailInput = browserWindow.textFields.firstMatch
        XCTAssertTrue(emailInput.waitForExistence(timeout: timeout))
        emailInput.click()
        emailInput.typeText(email)

        let passwordInput = browserWindow.secureTextFields.firstMatch
        passwordInput.click()
        passwordInput.typeText(password)

        browserWindow.buttons[webLoginButton].click()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))
    }

    func testLogout() {
        let app = XCUIApplication()
        app.activate()

        let view = app.windows.firstMatch.groups[appView]
        view.click()

        clickAlert()

        let browser = XCUIApplication(bundleIdentifier: browserApp)
        let browserWindow = browser
            .windows
            .firstMatch
            .webViews
            .firstMatch
        XCTAssertTrue(browserWindow.waitForExistence(timeout: timeout))

        let sessionButton = browserWindow.staticTexts[email]
        XCTAssertTrue(sessionButton.waitForExistence(timeout: timeout))
        sessionButton.click()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))

        sleep(5) // Wait for login button to change into logout button
        view.click()

        clickAlert()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))
    }
}

private extension SmokeTests {
    func clickAlert() {
        let dialog = XCUIApplication(bundleIdentifier: "com.apple.UserNotificationCenter")
            .dialogs
            .firstMatch
        XCTAssertTrue(dialog.waitForExistence(timeout: timeout))

        let continueButton = dialog.buttons[continueButton]
        XCTAssertTrue(continueButton.waitForExistence(timeout: timeout))
        continueButton.click()
    }
}
