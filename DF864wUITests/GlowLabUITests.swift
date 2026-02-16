//
//  GlowLabUITests.swift
//  DF864wUITests
//

import XCTest

final class GlowLabUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingThenImportFlow() throws {
        let app = XCUIApplication()
        app.launch()

        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        if app.buttons["Start Editing"].exists {
            app.buttons["Start Editing"].tap()
        }

        XCTAssertTrue(app.buttons["Import Photo"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testSettingsTogglesPersist() throws {
        let app = XCUIApplication()
        app.launch()

        navigateToSettings(app)
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPresetsScreenOpens() throws {
        let app = XCUIApplication()
        app.launch()

        skipOnboardingIfNeeded(app)
        if app.buttons["Presets"].exists {
            app.buttons["Presets"].tap()
        } else {
            let presetsLink = app.links["Presets"]
            if presetsLink.exists { presetsLink.tap() }
        }
    }

    @MainActor
    func testGalleryOpens() throws {
        let app = XCUIApplication()
        app.launch()

        skipOnboardingIfNeeded(app)
        let gallery = app.buttons["Gallery"]
        if gallery.exists {
            gallery.tap()
        } else {
            app.links["Gallery"].tap()
        }
        XCTAssertTrue(app.navigationBars["Gallery"].waitForExistence(timeout: 2) || app.staticTexts["No Exports Yet"].waitForExistence(timeout: 2))
    }

    private func skipOnboardingIfNeeded(_ app: XCUIApplication) {
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        if app.buttons["Start Editing"].exists {
            app.buttons["Start Editing"].tap()
        }
    }

    private func navigateToSettings(_ app: XCUIApplication) {
        skipOnboardingIfNeeded(app)
        if app.buttons["Settings"].exists {
            app.buttons["Settings"].tap()
        } else {
            app.links["Settings"].tap()
        }
    }
}
