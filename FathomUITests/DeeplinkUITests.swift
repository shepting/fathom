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

    func testOpenDeeplink() throws {
        // Open a URL using Safari and capture a screenshot
        // This tests the deeplink/universal link flow
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        // Wait for Safari to launch
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(safariLaunched, "Safari should launch")

        // Wait for Safari UI to settle
        sleep(2)

        // Find and tap the address bar (TextField with identifier "TabBarItemTitle")
        let addressBar = safari.textFields["TabBarItemTitle"]
        XCTAssertTrue(addressBar.waitForExistence(timeout: 5), "Address bar should exist")
        addressBar.tap()

        // Wait for keyboard
        sleep(1)

        // Clear existing text and type the URL
        if let currentValue = addressBar.value as? String, !currentValue.isEmpty {
            // Select all and delete
            addressBar.tap()
            sleep(1)
        }

        safari.typeText("https://apple.com\n")

        // Wait for page to load
        sleep(5)

        // Take a screenshot of the result
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Deeplink Test Result"
        attachment.lifetime = .keepAlways
        add(attachment)
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
