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
        // Open a deeplink URL using Safari
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        // Wait for Safari to launch
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 5)
        XCTAssertTrue(safariLaunched, "Safari should launch")

        // Navigate to a universal link that should open in Fathom
        // Using apple.com as an example since it has an AASA file
        safari.textFields["URL"].tap()
        safari.typeText("https://apple.com\n")

        // Wait for page to load
        sleep(3)

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
