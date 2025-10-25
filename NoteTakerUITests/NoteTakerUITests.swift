import XCTest

final class NoteTakerUITests: XCTestCase {
    func testAddClassAndNavigateToLearn() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.tabBars.buttons["Classes"].firstMatch
        if addButton.waitForExistence(timeout: 2) {
            addButton.tap()
        }

        let newClassButton = app.buttons["New Class"].firstMatch
        if newClassButton.waitForExistence(timeout: 2) {
            newClassButton.tap()
        }

        let nameField = app.textFields["Name"].firstMatch
        if nameField.waitForExistence(timeout: 2) {
            nameField.tap()
            nameField.typeText("UI Test Class")
        }

        let instructorField = app.textFields["Instructor"].firstMatch
        if instructorField.waitForExistence(timeout: 2) {
            instructorField.tap()
            instructorField.typeText("Coach")
        }

        app.buttons["Save"].firstMatch.tap()

        app.tabBars.buttons["Learn"].tap()
        XCTAssertTrue(app.navigationBars["Learn"].exists)
    }
}
