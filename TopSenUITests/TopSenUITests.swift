//
//  TopSenUITests.swift
//  TopSenUITests
//

import XCTest

final class TopSenUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMemoInputAndRelaunchPersistence() throws {
        let app = XCUIApplication()
        app.launchEnvironment["TOPSEN_USER_DEFAULTS_SUITE"] = "TopSenUITests.\(UUID().uuidString)"
        app.launch()

        var editor = app.textViews["memoEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.click()
        editor.typeText("TopSen UI test")
        XCTAssertTrue((editor.value as? String)?.contains("TopSen UI test") == true)

        app.terminate()
        app.launch()

        editor = app.textViews["memoEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertTrue((editor.value as? String)?.contains("TopSen UI test") == true)
    }

    @MainActor
    func testGlobalShortcutTogglesMemoVisibility() throws {
        let app = XCUIApplication()
        app.launchEnvironment["TOPSEN_USER_DEFAULTS_SUITE"] = "TopSenUITests.\(UUID().uuidString)"
        app.launch()

        let editor = app.textViews["memoEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))

        app.typeKey("m", modifierFlags: [.command, .shift])
        XCTAssertTrue(waitForExistence(editor, expected: false, timeout: 5))

        app.typeKey("m", modifierFlags: [.command, .shift])
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchEnvironment["TOPSEN_USER_DEFAULTS_SUITE"] = "TopSenUITests.Performance"
            app.launch()
        }
    }

    private func waitForExistence(
        _ element: XCUIElement,
        expected: Bool,
        timeout: TimeInterval
    ) -> Bool {
        let predicate = NSPredicate(format: "exists == %@", NSNumber(value: expected))
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
