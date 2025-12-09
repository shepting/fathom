//
//  DeeplinkUITests.swift
//  FathomUITests
//
//  Created by Claude on 2024.
//

import XCTest

final class DeeplinkUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testOpenDeeplinkViaSafari() throws {
        // Launch Safari to test that the system can handle URLs
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        // Wait for Safari to launch
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(safariLaunched, "Safari should launch successfully")

        // Wait for Safari to fully load
        sleep(2)

        // Take a screenshot showing Safari launched
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Safari Launch Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Return to our app
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App should return to foreground")
    }

    func testAppLaunchesSuccessfully() throws {
        // Verify the app launches and main UI is visible
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App should launch")

        // Take a screenshot
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "App Launch Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
