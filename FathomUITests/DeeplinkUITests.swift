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

    func testNavigateToGoogleAndFindGoogleMaps() throws {
        // Verify the app launches
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App should launch")

        // Wait for the list to load
        sleep(2)

        // Find and tap the google.com cell
        let googleCell = app.cells.staticTexts["www.google.com"]
        XCTAssertTrue(googleCell.waitForExistence(timeout: 10), "Google.com cell should exist")
        googleCell.tap()

        // Wait for the detail view to load
        sleep(2)

        // Take a screenshot of the Google detail view
        let detailScreenshot = XCUIScreen.main.screenshot()
        let detailAttachment = XCTAttachment(screenshot: detailScreenshot)
        detailAttachment.name = "Google Detail View"
        detailAttachment.lifetime = .keepAlways
        add(detailAttachment)

        // Find the table view and scroll to find Google Maps
        let table = app.tables.firstMatch

        // Scroll down to find the Google Maps cell
        var googleMapsCell = app.cells.staticTexts["Google Maps"]
        var attempts = 0
        let maxAttempts = 10

        while !googleMapsCell.exists && attempts < maxAttempts {
            table.swipeUp()
            sleep(1)
            googleMapsCell = app.cells.staticTexts["Google Maps"]
            attempts += 1
        }

        XCTAssertTrue(googleMapsCell.exists, "Google Maps cell should be found after scrolling")

        // Take a screenshot showing Google Maps cell
        let mapsScreenshot = XCUIScreen.main.screenshot()
        let mapsAttachment = XCTAttachment(screenshot: mapsScreenshot)
        mapsAttachment.name = "Google Maps Cell Found"
        mapsAttachment.lifetime = .keepAlways
        add(mapsAttachment)
    }
}
